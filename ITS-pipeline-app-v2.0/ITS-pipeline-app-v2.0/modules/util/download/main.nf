process DOWNLOAD_UNITE {
    tag "$params.db_release"
    label "process_low"

    conda (params.enable_conda ? "bash:5.0.018" : null)
    container "nakor/bash:5.1.4"

    output:
    path "*.fasta", emit: fasta

    script:
    def local_dir = "${baseDir}/../dbs"
    def file = (params.db_release == 'fungi') ? "${local_dir}/sh_general_release_04.04.2024.tgz" : "${local_dir}/sh_general_release_all_04.04.2024.tgz"

    if (params.db_release == 'fungi') {
        """
        tar xzf $file
        for fasta_file in sh_general_release*.fasta; do
            iconv -f utf-8 -t ascii \$fasta_file >> unite_fungi.fasta
        done
        rm -rf sh_general_release*
        """
    } else {
        """
        tar xzf $file
        gunzip -c $file | iconv -f utf-8 -t ascii > unite_all_eukaryotes.fasta
        echo "Cleaning up..."
        rm -f ${file}
        """
    }
}

// DEPRECATED: To download unite reference files from plutof
// process DOWNLOAD_UNITE {
//     tag "$params.db_release"
//     label "process_low"

//     conda (params.enable_conda ? "bash:5.0.018" : null)
//     container "nakor/bash:5.1.4"

//     output:
//     path "*.fasta", emit: fasta

//     script:
//     def root_url = "https://files.plutof.ut.ee/public/orig"

//     if (params.db_release == 'fungi') {
//         url_base = "${root_url}/1E/66"
//         file = "1E662B6EB320312A61E7E3218327F34C7DB09CFF8E4686A89EF47886822DA6AB.gz"
//         """
//         wget -qO- $url_base/$file | tar xz
//         iconv -f utf-8 -t ascii sh_general_release*/*.fasta \
//             > unite_fungi.fasta
//         rm -rf sh_general_release*
//         """
//     } else {
//         url_base = "${root_url}/BF/49"
//         file = "BF49FBF4B47314A1CC5238B280FC58BFB8CEBD44A8D45F4A2BF5B8A466715693.gz"
//         """
//         wget -qO- $url_base/$file \\
//             | gunzip \\
//             | iconv -f utf-8 -t ascii \\
//             > unite_all_eukaryotes.fasta
//         rm -f $file
//         """
//     }
// }

// Silva db reference files now packaged with zip app (16S pipeline)
process DOWNLOAD_SILVA_FOR_MOTHUR {
    tag "$params.db_release"
    label "process_low"

    conda (params.enable_conda ? "bash:5.0.018" : null)
    container "nakor/bash:5.1.4"

    output:
    path "*.tax", emit: tax
    path "*.align", emit: aln

    script:
    def local_dir = "${baseDir}/../dbs"
    def db_name = (params.db_release == 'nr') ? "silva.nr_v138_1" : "silva.seed_v138_1"
    def file = "${local_dir}/${db_name}.tgz"

    """
    tar xzf $file
    """
}

// DEPRECATED: To download silva reference files from mothur 
// process DOWNLOAD_SILVA_FOR_MOTHUR {
//     tag "$params.db_release"
//     label "process_low"

//     conda (params.enable_conda ? "bash:5.0.018" : null)
//     container "nakor/bash:5.1.4"

//     output:
//     path "*.tax", emit: tax
//     path "*.align", emit: aln

//     script:
//     def url_base = "https://mothur.s3.us-east-2.amazonaws.com/wiki"
// 	db_name = "silva.${params.db_release}_v138_1"
//     """
//     wget -qO- ${url_base}/${db_name}.tgz | tar xz
//     """
// }

process DOWNLOAD_RDP_FOR_DADA2 {
    tag "$params.db_release"
    label "process_low"

    conda (params.enable_conda ? "bash:5.0.018" : null)
    container "nakor/bash:5.1.4"

    output:
    path "*.fa", emit: fasta

    script:
    url_base = "https://zenodo.org/record/4587955/files"
    file = "silva_nr99_v138.1_wSpecies_train_set.fa.gz?download=1"
    """
    wget -qO- "$url_base/$file" | gunzip \\
        > silva_nr99_v138.1_wSpecies_train_set.fa
    """
}

