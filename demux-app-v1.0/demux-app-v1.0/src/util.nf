// Help function for demux pipeline

def helpMessage() {
    log.info"""
    ===================================
    nf-multithreaded-demultiplexing
    ===================================

    Usage:
    nextflow run nextflow-demux -profile local --inputdir test/

    For more detailed information, see https://metagenomics-pipelines.readthedocs.io/en/latest/
    
    ---------------------------------- Mandatory arguments ----------------------------------------

    --inputdir  Path to data folder. It should include:
				- 2 index fastq files (unzipped) matching the glob pattern "*_I{1,2}*.fastq.gz"
				- 2 read fastq files (unzipped) matching the glob pattern "*_R{1,2}*.fastq.gz"
				- 1 barcode file (extension: ".csv"), comma separated, with no header and
				  three columns (sample name, forward barcode, RevCompl of reverse barcode)
    -profile    Choose a configuration. Choices are local, hpc, gcp and
                their corresponding test configurations (by adding _test)

    ---------------------------------- Optional arguments ----------------------------------------

    --singleBarcoded     Set this flag if your reads are single-barcoded.
    --singleEnd          Set this flag if your reads are single-end
    --reverseComplement  Set this flag if you want to reverse complement the reverse barcodes
    --outdir             Path to output folder. Default: "./demultiplexed"
    --max_mismatches     Maximum number of allowed mismatches between index and barcode. Default: 1
    --n_per_file         Number of reads per file (processed in parallel). Default: 1e6
    --n_bases            Number of bases to use to build the error model. Default: 1e5
    --matching           By default, the order in which the barcodes pair match the index pair is 
                         inferred from the data. To change this behavior, set this parameter to 
                         either "ordered" or "reversed". Default: "auto"
    """.stripIndent()
}

// Show help message
params.help = false
if (params.help){
    helpMessage()
    exit 0
}

def saveParams() {
    def summary = [:]
    summary['Single barcoded'] = params.singleBarcoded
    summary['Single end'] = params.singleEnd
    summary['Reverse complement the reverse index'] = params.reverseComplement
    summary['Max mismatches with barcode'] = params.max_mismatches
    summary['Nb of bases for error model'] = params.n_bases
    summary['Reads per file (for multithreading)'] = params.n_per_file
    summary['Mapping order between (fwd, rev) indexes and (fwd, rev) barcodes'] = params.matching

    file(params.outdir).mkdir()
    File f = new File("${params.outdir}/parameters_summary.log")
    f.write("====== Parameter summary =====\n")
    summary.each { key, val -> f.append("\n${key.padRight(50)}: ${val}") }
}
