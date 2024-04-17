// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

options = initOptions(params.options)

process FASTTREE {
    tag "$meta.id"
    label "process_high"
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options,
                                        publish_dir:getSoftwareName(task.process)) }

    conda (params.enable_conda ? "bioconda::fasttree" : null)
    container "quay.io/biocontainers/fasttree:2.1.8--h779adbc_6"

    input:
    tuple val(meta), path(repfasta)

    output:
    tuple val(meta), path("*.nwk"), emit: nwk
    path "*.version.txt", emit: version

    script:
    def software = getSoftwareName(task.process)
    def procname = "${task.process.tokenize(':')[-1].toLowerCase()}"
    def outprefix = "${procname}.${meta.id}"	
    """
    FastTree -nt $repfasta > fasttree.${meta.id}.nwk

    fasttree 2>&1 >/dev/null | head -1 | sed 's/.*version \\([0-9\\.]*\\).*/\\1/g' \\
    > ${software}.version.txt
    """
}
