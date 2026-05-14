#!/usr/bin/env nextflow

nextflow.enable.dsl=2

params.inputdir = "${params.inputdir}"

// Functions
include { helpMessage; saveParams } from "./util.nf"

process Fastqc {
    tag "Fastqc"
    publishDir params.outdir, mode: "copy", pattern: "*.html"
    label "high_computation"
    label "python_script"

    input:
    tuple val(v), path(fastqs)

    output:
    path "*.html" 

    script:
    """
    fastqc -o . --threads ${task.cpus} ${fastqs}
    """
}

process GuessMatchOrder {
    tag "GuessMatchOrder"
    label "low_computation"
    label "python_script"
    publishDir params.outdir, pattern: "barcodes_ok.csv"

    input:
    tuple val(v), path(fastqs)
    path meta

    output:
    path "barcodes_ok.csv", emit: barcodes_file

    script:
    """
    #!/usr/bin/env bash

    bash ${params.script_dir}/demux/guess_matching_order.sh ${meta} ${params.matching} ${params.reverseComplement} ${fastqs} > barcodes_ok.csv
    """
}

process To_h5 {
    tag "to_h5_${split}"
    label "python_script"
    label "medium_computation"

    input:
    tuple val(split), val(v), path(fastqs)

    output:
    tuple val(split), path("*.h5"), emit: h5_files
    path "*.h5", emit: h5_files_for_error_model

    script:
    """
    python3 ${params.script_dir}/demux/load.py --fastqs ${fastqs} --split ${split} \$([ "${params.reverseComplement}" == true ] && echo "--rc" || echo "")
    """
}

process ErrorModel {
    tag "ErrorModel"
    publishDir "${params.outdir}/other", mode: "copy", pattern: "*.{h5,html}"
    label "python_script"
    label "high_computation"
    
    input:
    path h5
    path meta

    output:
    path "transition_probs.h5", emit: error_model
    path "*.html"

    script:
    """
    python3 ${params.script_dir}/demux/error_model.py --max_dist ${params.max_mismatches} --n_bases ${params.n_bases.toInteger()} --meta ${meta}
    """
}

process IndexMapping {
    tag "IndexMapping_${split}"
    publishDir "${params.outdir}/sample_idx_mapping", mode: "copy", pattern: "*.tsv"
    label "python_script"
    label "high_computation"

    stageInMode "copy"
    
    input:
    tuple val(split), path(h5)
    path model
    path meta

    output:
    tuple val(split), path("demux_info*.tsv"), emit: demux_info
    path "sample_counts*.csv", emit: sample_counts

    script:
    """
    python3 ${params.script_dir}/demux/dada_demux_index.py --data ${h5} --meta ${meta} --error-model ${model} --split ${split} --max-mismatches ${params.max_mismatches}
    """
}

process SampleSizeDistribution {
    tag "SampleSizeDistribution"
    publishDir params.outdir, mode: "copy", pattern: "*.{html,csv}"
    label "python_script"
    label "medium_computation"

    input:
    path f

    output:
    path "*.html"
    path "sample_sizes.csv"

    script:
    """
    python3 ${params.script_dir}/demux/plot_sample_size_distribution.py
    """
}

process WriteSampleFastq {
    tag "WriteSampleFastq_${split}"
    stageOutMode "move"
    label "python_script"
    label "low_computation"
    
    input:
    tuple val(split), val(v), path(fastqs), path(demux_info)

    output:
    path "*.fastq", optional: true, emit: demux_seq_split

    script:
    """
    python3 ${params.script_dir}/demux/demux_fastq.py --fastqs ${fastqs} --mapping ${demux_info}
    """
}

process Gzip {
    tag "Gzip"
    label "high_computation"

    input:
    path f

    script:
    """
    ls ${params.outdir}/reads/*.fastq | xargs -P ${task.cpus} gzip
    """    
}

workflow demux_pipeline {
    take:
    inputdir
    indexes
    meta

    main:
    // Channel definitions
    ch_input_seq = Channel
        .fromFilePairs("${params.inputdir}/*_R{1,2}*.fastq*", size: params.singleEnd ? 1 : 2, flat: true)
        .ifEmpty { error "Cannot find any sequencing read in ${params.inputdir}/" }

    ch_input_index = Channel
        .fromFilePairs("${params.inputdir}/*_I{1,2}*.fastq*", size: params.singleBarcoded ? 1 : 2 , flat: true)
        .ifEmpty { error "Cannot find any indexing read in ${params.inputdir}/" }

    // Process calls
    Fastqc(ch_input_seq.map { [it[0], it[1..-1]] })

    ch_meta = Channel.fromPath("${params.inputdir}/*.csv")
    GuessMatchOrder(ch_input_index.map { [it[0], it[1..-1]] }, ch_meta)

    // Handle index splitting based on params.singleBarcoded
    if (params.singleBarcoded) {
        IDX_SPLIT = ch_input_index
            .splitFastq(by: params.n_per_file.toInteger(), file: true)
            .map { [it[0], it[1..-1]] }
    } else {
        IDX_SPLIT = ch_input_index
            .splitFastq(by: params.n_per_file.toInteger(), file: true, pe: true)
            .map { [it[0], it[1..-1]] }
    }

    SEQ_SPLIT = ch_input_seq
        .splitFastq(by: params.n_per_file.toInteger(), file: true, pe: !params.singleEnd)
        .map { [it[0], it[1..-1]] }

    INPUT_IDX_SPLIT = IDX_SPLIT
        .toList()
        .flatMap { list -> list.withIndex().collect { item, idx -> [idx + 1] + item } }

    INPUT_SEQ_SPLIT = SEQ_SPLIT
        .toList()
        .flatMap { list -> list.withIndex().collect { item, idx -> [idx + 1] + item } }

    To_h5(INPUT_IDX_SPLIT)

    ErrorModel(To_h5.out.h5_files_for_error_model.collect(), GuessMatchOrder.out.barcodes_file)

    IndexMapping(To_h5.out.h5_files, ErrorModel.out.error_model, GuessMatchOrder.out.barcodes_file)

    SampleSizeDistribution(IndexMapping.out.sample_counts.collect())

    WriteSampleFastq(INPUT_SEQ_SPLIT.join(IndexMapping.out.demux_info))

    DEMUX_SEQ = WriteSampleFastq.out.demux_seq_split
        .flatten()
        .collectFile(storeDir: "${params.outdir}/reads", sort: true)

    Gzip(DEMUX_SEQ.collect())
}

workflow {
    inputdir = Channel.fromFilePairs(params.inputdir, size: params.singleEnd ? 1 : 2)
        .map{[ [id: it[0]], it[1] ]}
    indexes = Channel.fromFilePairs("${params.inputdir}/*_I{1,2}*.fastq*", size: params.singleBarcoded ? 1 : 2 , flat: true)
    meta = Channel.fromPath("${params.inputdir}/*.csv")
    saveParams()
    demux_pipeline(inputdir, indexes, meta)
}
