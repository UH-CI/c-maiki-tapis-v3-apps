# app_configs.py
"""
Configuration file for longer TAPIS application parameters
"""

AMPLISEQ_DB_DROPDOWN = ["--dada_ref_taxonomy silva=138",
                        "--dada_ref_taxonomy coidb",
                        "--dada_ref_taxonomy coidb=221216",
                        "--dada_ref_taxonomy gtdb",
                        "--dada_ref_taxonomy gtdb=R05-RS95",
                        "--dada_ref_taxonomy gtdb=R06-RS202",
                        "--dada_ref_taxonomy gtdb=R07-RS207",
                        "--dada_ref_taxonomy gtdb=R08-RS214",
                        "--dada_ref_taxonomy gtdb=R09-RS220",
                        "--dada_ref_taxonomy midori2-co1",
                        "--dada_ref_taxonomy midori2-co1=gb250",
                        "--dada_ref_taxonomy pr2",
                        "--dada_ref_taxonomy pr2=4.13.0",
                        "--dada_ref_taxonomy pr2=4.14.0",
                        "--dada_ref_taxonomy pr2=5.0.0",
                        "--dada_ref_taxonomy rdp",
                        "--dada_ref_taxonomy rdp=18",
                        "--dada_ref_taxonomy sbdi-gtdb",
                        "--dada_ref_taxonomy sbdi-gtdb=R09-RS220-1",
                        "--dada_ref_taxonomy sbdi-gtdb=R08-RS214-1",
                        "--dada_ref_taxonomy sbdi-gtdb=R07-RS207-1",
                        "--dada_ref_taxonomy sbdi-gtdb=R06-RS202-3",
                        "--dada_ref_taxonomy sbdi-gtdb=R06-RS202-1",
                        "--dada_ref_taxonomy silva",
                        "--dada_ref_taxonomy silva=132",
                        "--dada_ref_taxonomy unite-alleuk",
                        "--dada_ref_taxonomy unite-alleuk=9.0",
                        "--dada_ref_taxonomy unite-alleuk=8.3",
                        "--dada_ref_taxonomy unite-alleuk=8.2",
                        "--dada_ref_taxonomy unite-fungi",
                        "--dada_ref_taxonomy unite-fungi=9.0",
                        "--dada_ref_taxonomy unite-fungi=8.3",
                        "--dada_ref_taxonomy unite-fungi=8.2",
                        "--dada_ref_taxonomy zehr-nifh",
                        "--dada_ref_taxonomy zehr-nifh=2.5.0"]

AMPLISEQ_TEST_ARGS = [
                {"name": "FW_primer", "arg": "--FW_primer GTGYCAGCMGCCGCGGTAA", "description": "Forward primer sequence - Ignored if skipping cutadapt", "inputMode": "REQUIRED", "notes": {"Optional": "true", "Info":"See https://earthmicrobiome.org/protocols-and-standards/ for a reference on primers"} },
                {"name": "RV_primer", "arg": "--RV_primer GGACTACNVGGGTWTCTAAT", "description": "Reverse primer sequence - Ignored if skipping cutadapt", "inputMode": "REQUIRED", "notes": {"Optional": "true", "Info":"See https://earthmicrobiome.org/protocols-and-standards/ for a reference on primers"} },
                {"name": "metadata", "arg": "--metadata ''", "description": "Path to metadata sheet, when missing most downstream analysis are skipped (barplots, PCoA plots, ...).", "inputMode": "REQUIRED", "notes": {"filePath": "true"} },
                {"name": "Skip Cutadapt", "arg": "--skip_cutadapt", "description": "Skip primer trimming with cutadapt", "inputMode": "INCLUDE_BY_DEFAULT"},
                {"name": "Save Intermediates", "arg": "--save_intermediates", "description": "Save intermediate results such as QIIME2's qza and qzv files", "inputMode": "INCLUDE_ON_DEMAND"},

                {"name": "Illumina NovaSeq Reads", "arg": "--illumina_novaseq", "description": "If data has binned quality scores such as Illumina NovaSeq", "inputMode": "INCLUDE_ON_DEMAND", "notes": {"Advanced": "true"}},
                {"name": "PacBio Reads", "arg": "--pacbio", "description": "If data is single-ended PacBio reads instead of Illumina", "inputMode": "INCLUDE_ON_DEMAND", "notes": {"Advanced": "true"}},
                {"name": "IonTorrent Reads", "arg": "--iontorrent", "description": "If data is single-ended IonTorrent reads instead of Illumina", "inputMode": "INCLUDE_ON_DEMAND", "notes": {"Advanced": "true"}},
                {"name": "Single End Reads", "arg": "--single_end", "description": "If data is single-ended Illumina reads instead of paired-end", "inputMode": "INCLUDE_BY_DEFAULT", "notes": {"Advanced": ""}},
                {"name": "Illumina Paired End Reads", "arg": "--illumina_pe_its", "description": "If analysing ITS amplicons or any other region with large length variability with Illumina paired end reads", "inputMode": "INCLUDE_ON_DEMAND", "notes": {"Advanced": "true"}},
    
#                 {"name": "multiple_sequencing_runs", "arg": "--multiple_sequencing_runs", "description": "Multiple sequencing runs?", "inputMode": "INCLUDE_ON_DEMAND", "notes": {"Info":"See https://earthmicrobiome.org/protocols-and-standards/ for a reference on primers"}},
                {"name": "extension", "arg": "--extension \"/*_R{1,2}.fastq.gz\"", "description": "Extension If using `--input_folder`: naming of sequencing files", "inputMode": "REQUIRED", "notes": {"Info":"See ..."}},
#                 {"name": "max_ee", "arg": "--max_ee 3", "description": "Maximum number of expected errors per read (>0). DADA2 read filtering option", "inputMode": "REQUIRED"},
                
                # Connected args
                {"name": "min_read_counts", "arg": "--min_read_counts 100", "description": "Set read count threshold for failed samples", "inputMode": "REQUIRED"},
                {"name": "Ignore Empty Input Files", "arg": "--ignore_empty_input_files", "description": "Ignore input files with too few reads", "inputMode": "INCLUDE_BY_DEFAULT"},
                
                {"name": "Ignore Failed Trimmings", "arg": "--ignore_failed_trimming", "description": "Ignore files with too few reads after trimming", "inputMode": "INCLUDE_BY_DEFAULT"},
                {"name": "trunclenf", "arg": "--trunclenf 250", "description": "DADA2 read truncation value for forward strand, set this to 0 for no truncation", "inputMode": "REQUIRED"},
                {"name": "trunclenr", "arg": "--trunclenr 190", "description": "DADA2 read truncation value for reverse strand, set this to 0 for no truncation", "inputMode": "REQUIRED"},
                {"name": "trunc_qmin", "arg": "--trunc_qmin 25", "description": "If --trunclenf and --trunclenr are not set, these values will be automatically determined using this median quality score", "inputMode": "REQUIRED"},
                {"name": "trunc_rmin", "arg": "--trunc_rmin 0.75", "description": "Assures that values chosen with --trunc_qmin will retain a fraction of reads", "inputMode": "REQUIRED"},

#                 {"name": "max_ee", "arg": "--max_ee 2", "description": "DADA2 read filtering option", "inputMode": "REQUIRED"},
#                 {"name": "min_len", "arg": "--min_len 20", "description": "DADA2 read filtering option", "inputMode": "REQUIRED"},
#                 {"name": "max_len", "arg": "--max_len", "description": "DADA2 read filtering option", "inputMode": "REQUIRED"},
                {"name": "Retain Untrimmed", "arg": "--retain_untrimmed", "description": "Cutadapt will retain untrimmed reads", "inputMode": "INCLUDE_ON_DEMAND"},
                {"name": "cutadapt_min_overlap", "arg": "--cutadapt_min_overlap 3", "description": "Sets the minimum overlap for valid matches of primer sequences with reads for cutadapt (-O)", "inputMode": "REQUIRED", "notes": {"Optional": "true"} },
                {"name": "cutadapt_max_error_rate", "arg": "--cutadapt_max_error_rate 0.1", "description": "Sets the maximum error rate for valid matches of primer sequences with reads for cutadapt (-e)", "inputMode": "REQUIRED", "notes": {"Optional": "true"} },
                {"name": "Ignore Failed Filtering", "arg": "--ignore_failed_filtering", "description": "Ignore files with too few reads after quality filtering", "inputMode": "INCLUDE_BY_DEFAULT"},
                
                {"name": "sample_inference", "arg": "--sample_inference independent", "description": "Mode of sample inference: \"independent\", \"pooled\" or \"pseudo\"", "inputMode": "REQUIRED", "notes": {"Dropdown": ["--sample_inference independent","--sample_inference pooled","--sample_inference pseudo"]}},
    
                {"name": "VSEARCH Cluster", "arg": "--vsearch_cluster", "description": "Post-cluster ASVs with VSEARCH", "inputMode": "INCLUDE_BY_DEFAULT"},
                {"name": "vsearch_cluster_id", "arg": "--vsearch_cluster_id 0.97", "description": "Pairwise Identity value used when post-clustering ASVs if `--vsearch_cluster` option is used (default: 0.97)", "inputMode": "REQUIRED"},
                
                {"name": "dada_ref_taxonomy", "arg": "--dada_ref_taxonomy silva=138", "description": "Name of supported database, and optionally also version number. https://nf-co.re/ampliseq/2.11.0/parameters/#dada_ref_taxonomy", "inputMode": "REQUIRED", "notes": {"Optional": "", "Dropdown": AMPLISEQ_DB_DROPDOWN}},
                {"name": "dada_ref_tax_custom", "arg": "--dada_ref_tax_custom ''", "description": "Path to a custom DADA2 reference taxonomy database", "inputMode": "REQUIRED", "notes": {"Optional": "true"} },
                {"name": "dada_ref_tax_custom_sp ", "arg": "--dada_ref_tax_custom_sp ''", "description": "Path to a custom DADA2 reference taxonomy database for species assignment", "inputMode": "REQUIRED", "notes": {"Optional": "true"} },
                {"name": "dada_assign_taxlevels", "arg": "--dada_assign_taxlevels ''", "description": "Comma separated list of taxonomic levels used in DADA2's assignTaxonomy function", "inputMode": "REQUIRED", "notes": {"Optional": "true"} },

                {"name": "DADA Taxonomy Reverse Complement", "arg": "--dada_taxonomy_rc", "description": "If reverse-complement of each sequences will be also tested for classification", "inputMode": "INCLUDE_ON_DEMAND", "notes" : {"Info": "..."}},
                
#                 # For future development
#                 {"name": "pplace_tree", "arg": "--pplace_tree", "description": "Newick file with reference phylogenetic tree. Requires also `--pplace_aln` and `--pplace_model`", "inputMode": "REQUIRED", "notes": {"Optional": "true"}},
#                 {"name": "pplace_aln", "arg": "--pplace_aln", "description": "File with reference sequences. Requires also `--pplace_tree` and `--pplace_model`", "inputMode": "REQUIRED", "notes": {"Optional": "true"}},
#                 {"name": "pplace_model", "arg": "--pplace_model", "description": "Phylogenetic model to use in placement, e.g. 'LG+F' or 'GTR+I+F'. Requires also `--pplace_tree` and `--pplace_aln`", "inputMode": "REQUIRED", "notes": {"Optional": "true"}},
#                 {"name": "pplace_alnmethod", "arg": "--pplace_alnmethod hmmer", "description": "Method used for alignment, \"hmmer\" or \"mafft\"", "inputMode": "REQUIRED", "notes": {"Optional": "true"}},
#                 {"name": "pplace_taxonomy", "arg": "--pplace_taxonomy", "description": "Tab-separated file with taxonomy assignments of reference sequences", "inputMode": "REQUIRED", "notes": {"Optional": "true"}},
#                 {"name": "pplace_name", "arg": "--pplace_name", "description": "A name for the run", "inputMode": "REQUIRED", "notes": {"Optional": "true"}},

                {"name": "PICRUSt", "arg": "--picrust", "description": "If the functional potential of the bacterial community is predicted", "inputMode": "INCLUDE_ON_DEMAND"},
                {"name": "exclude_taxa", "arg": "--exclude_taxa 'mitochondria,chloroplast,unknown'", "description": "Comma separated list of unwanted taxa, to skip taxa filtering use \"none\"", "inputMode": "REQUIRED", "notes": {"Optional": "true", "Info": "..."} },
                {"name": "min_frequency", "arg": "--min_frequency 1", "description": "Abundance filtering", "inputMode": "REQUIRED", "notes": {"Info": "..."} },
                {"name": "min_samples", "arg": "--min_samples 1", "description": "Prevalence filtering", "inputMode": "REQUIRED", "notes": {"Info": "..."} },
                
                # New option
                {"name": "diversity_rarefaction_depth", "arg": "--diversity_rarefaction_depth 500", "description": "Minimum rarefaction depth for diversity analysis", "inputMode": "REQUIRED", "notes": {"Optional": "true", "Info": "..."}},

#                 {"name": "skip_fastqc", "arg": "--skip_fastqc", "description": "Skip FastQC", "inputMode": "INCLUDE_ON_DEMAND"},
#                 {"name": "skip_dada_quality", "arg": "--skip_dada_quality", "description": "Skip quality check with DADA2", "inputMode": "INCLUDE_ON_DEMAND"},
                {"name": "Skip Barrnap", "arg": "--skip_barrnap", "description": "Skip annotating SSU matches", "inputMode": "INCLUDE_ON_DEMAND"},
#                 {"name": "skip_qiime", "arg": "--skip_qiime", "description": "Skip all steps that are executed by QIIME2", "inputMode": "INCLUDE_ON_DEMAND"},
#                 {"name": "Skip Qiime Downstream", "arg": "--skip_qiime_downstream", "description": "Skip steps that are executed by QIIME2 except for taxonomic classification", "inputMode": "INCLUDE_ON_DEMAND"},
#                 {"name": "Skip Alpha Rarefaction", "arg": "--skip_alpha_rarefaction", "description": "Skip alpha rarefaction", "inputMode": "INCLUDE_ON_DEMAND"},
#                 {"name": "Skip Diversity Indices", "arg": "--skip_diversity_indices", "description": "Skip alpha and beta diversity analysis", "inputMode": "INCLUDE_ON_DEMAND"}
]

AMPLISEQ_CONDENSED_AMP_ARGS = [
                {"name": "FW_primer", "arg": "--FW_primer GTGYCAGCMGCCGCGGTAA", "description": "Forward primer sequence", "inputMode": "REQUIRED", "notes": {"Optional": "Test3"} },
                {"name": "RV_primer", "arg": "--RV_primer GGACTACNVGGGTWTCTAAT", "description": "Reverse primer sequence", "inputMode": "REQUIRED", "notes": {"Optional": "Test4"} },
                {"name": "metadata", "arg": "--metadata ''", "description": "Path to metadata sheet, when missing most downstream analysis are skipped (barplots, PCoA plots, ...).", "inputMode": "REQUIRED", "notes": {"filePath": "true"} },
                {"name": "skip_cutadapt", "arg": "--skip_cutadapt", "description": "Skip primer trimming with cutadapt", "inputMode": "INCLUDE_ON_DEMAND"},
#                 {"name": "save_intermediates", "arg": "--save_intermediates", "description": "Save intermediate results such as QIIME2's qza and qzv files", "inputMode": "INCLUDE_ON_DEMAND"},
                {"name": "Illumina NovaSeq Reads", "arg": "--illumina_novaseq", "description": "If data has binned quality scores such as Illumina NovaSeq", "inputMode": "INCLUDE_ON_DEMAND"},
                {"name": "PacBio Reads", "arg": "--pacbio", "description": "If data is single-ended PacBio reads instead of Illumina", "inputMode": "INCLUDE_ON_DEMAND"},
                {"name": "IonTorrent Reads", "arg": "--iontorrent", "description": "If data is single-ended IonTorrent reads instead of Illumina", "inputMode": "INCLUDE_ON_DEMAND"},
                {"name": "Single End Reads", "arg": "--single_end", "description": "If data is single-ended Illumina reads instead of paired-end", "inputMode": "INCLUDE_ON_DEMAND"},
                {"name": "Illumina Paired End Reads", "arg": "--illumina_pe_its", "description": "If analysing ITS amplicons or any other region with large length variability with Illumina paired end reads", "inputMode": "INCLUDE_ON_DEMAND"},
#                 {"name": "multiple_sequencing_runs", "arg": "--multiple_sequencing_runs", "description": "Multiple sequencing runs?", "inputMode": "INCLUDE_ON_DEMAND"},
#                 {"name": "extension", "arg": "--extension \"/*_R{1,2}.fastq.gz\"", "description": "Extension If using `--input_folder`: naming of sequencing files", "inputMode": "REQUIRED"},
                {"name": "min_read_counts", "arg": "--min_read_counts 100", "description": "Set read count threshold for failed samples", "inputMode": "REQUIRED"},
                {"name": "Ignore Empty Input Files", "arg": "--ignore_empty_input_files", "description": "Ignore input files with too few reads", "inputMode": "INCLUDE_BY_DEFAULT"},
                {"name": "Ignore Failed Trimmings", "arg": "--ignore_failed_trimming", "description": "Ignore files with too few reads after trimming", "inputMode": "INCLUDE_BY_DEFAULT"},
                {"name": "trunclenf", "arg": "--trunclenf 220", "description": "DADA2 read truncation value for forward strand, set this to 0 for no truncation", "inputMode": "REQUIRED"},
                {"name": "trunclenr", "arg": "--trunclenr 190", "description": "DADA2 read truncation value for reverse strand, set this to 0 for no truncation", "inputMode": "REQUIRED"},
#                 {"name": "trunc_qmin", "arg": "--trunc_qmin 25", "description": "If --trunclenf and --trunclenr are not set, these values will be automatically determined using this median quality score", "inputMode": "REQUIRED"},

#                 {"name": "max_ee", "arg": "--max_ee 2", "description": "DADA2 read filtering option", "inputMode": "REQUIRED"},
#                 {"name": "min_len", "arg": "--min_len 50", "description": "DADA2 read filtering option", "inputMode": "REQUIRED"},
#                 {"name": "max_len", "arg": "--max_len", "description": "DADA2 read filtering option", "inputMode": "REQUIRED"},
                {"name": "Ignore Failed Filtering", "arg": "--ignore_failed_filtering", "description": "Ignore files with too few reads after quality filtering", "inputMode": "INCLUDE_BY_DEFAULT"},
#                 {"name": "vsearch_cluster", "arg": "--vsearch_cluster", "description": "Post-cluster ASVs with VSEARCH", "inputMode": "REQUIRED"},
#                 {"name": "vsearch_cluster_id", "arg": "--vsearch_cluster_id 0.97", "description": "Pairwise Identity value used when post-clustering ASVs if `--vsearch_cluster` option is used (default: 0.97)", "inputMode": "REQUIRED"},
                {"name": "dada_ref_taxonomy", "arg": "--dada_ref_taxonomy silva=138", "description": "Name of supported database, and optionally also version number. https://nf-co.re/ampliseq/2.11.0/parameters/#dada_ref_taxonomy", "inputMode": "REQUIRED", "notes": {"Optional": "", "Dropdown": AMPLISEQ_DB_DROPDOWN}},
#                 {"name": "dada_ref_tax_custom", "arg": "--dada_ref_tax_custom", "description": "Path to a custom DADA2 reference taxonomy database", "inputMode": "REQUIRED"},
#                 {"name": "dada_ref_tax_custom_sp", "arg": "--dada_ref_tax_custom_sp", "description": "Path to a custom DADA2 reference taxonomy database for species assignment", "inputMode": "REQUIRED"},
#                 {"name": "dada_assign_taxlevels", "arg": "--dada_assign_taxlevels", "description": "Comma separated list of taxonomic levels used in DADA2's assignTaxonomy function", "inputMode": "REQUIRED"},
                {"name": "DADA Taxonomy Reverse Complement", "arg": "--dada_taxonomy_rc", "description": "If reverse-complement of each sequences will be also tested for classification", "inputMode": "INCLUDE_ON_DEMAND"},
                {"name": "PICRUSt", "arg": "--picrust", "description": "If the functional potential of the bacterial community is predicted", "inputMode": "INCLUDE_ON_DEMAND"},
#                 {"name": "exclude_taxa", "arg": "--exclude_taxa mitochondria,chloroplast", "description": "Comma separated list of unwanted taxa, to skip taxa filtering use \"none\"", "inputMode": "REQUIRED"},
#                 {"name": "min_frequency", "arg": "--min_frequency 1", "description": "Abundance filtering", "inputMode": "REQUIRED"},
#                 {"name": "min_samples", "arg": "--min_samples 1", "description": "Prevalence filtering", "inputMode": "REQUIRED"},
#                 {"name": "skip_fastqc", "arg": "--skip_fastqc", "description": "Skip FastQC", "inputMode": "INCLUDE_ON_DEMAND"},
#                 {"name": "skip_dada_quality", "arg": "--skip_dada_quality", "description": "Skip quality check with DADA2", "inputMode": "INCLUDE_ON_DEMAND"},
                {"name": "Skip Barrnap", "arg": "--skip_barrnap", "description": "Skip annotating SSU matches", "inputMode": "INCLUDE_ON_DEMAND"},
#                 {"name": "skip_qiime", "arg": "--skip_qiime", "description": "Skip all steps that are executed by QIIME2", "inputMode": "INCLUDE_ON_DEMAND"},
                {"name": "Skip Qiime Downstream", "arg": "--skip_qiime_downstream", "description": "Skip steps that are executed by QIIME2 except for taxonomic classification", "inputMode": "INCLUDE_BY_DEFAULT"},
            ]

AMPLISEQ_ITS_DB_DROPDOWN = [
                        "--dada_ref_taxonomy unite-alleuk",
                        "--dada_ref_taxonomy coidb",
                        "--dada_ref_taxonomy coidb=221216",
                        "--dada_ref_taxonomy gtdb",
                        "--dada_ref_taxonomy gtdb=R05-RS95",
                        "--dada_ref_taxonomy gtdb=R06-RS202",
                        "--dada_ref_taxonomy gtdb=R07-RS207",
                        "--dada_ref_taxonomy gtdb=R08-RS214",
                        "--dada_ref_taxonomy gtdb=R09-RS220",
                        "--dada_ref_taxonomy midori2-co1",
                        "--dada_ref_taxonomy midori2-co1=gb250",
                        "--dada_ref_taxonomy pr2",
                        "--dada_ref_taxonomy pr2=4.13.0",
                        "--dada_ref_taxonomy pr2=4.14.0",
                        "--dada_ref_taxonomy pr2=5.0.0",
                        "--dada_ref_taxonomy rdp",
                        "--dada_ref_taxonomy rdp=18",
                        "--dada_ref_taxonomy sbdi-gtdb",
                        "--dada_ref_taxonomy sbdi-gtdb=R09-RS220-1",
                        "--dada_ref_taxonomy sbdi-gtdb=R08-RS214-1",
                        "--dada_ref_taxonomy sbdi-gtdb=R07-RS207-1",
                        "--dada_ref_taxonomy sbdi-gtdb=R06-RS202-3",
                        "--dada_ref_taxonomy sbdi-gtdb=R06-RS202-1",
                        "--dada_ref_taxonomy silva",
                        "--dada_ref_taxonomy silva=132",
                        "--dada_ref_taxonomy silva=138",
                        "--dada_ref_taxonomy unite-alleuk=9.0",
                        "--dada_ref_taxonomy unite-alleuk=8.3",
                        "--dada_ref_taxonomy unite-alleuk=8.2",
                        "--dada_ref_taxonomy unite-fungi",
                        "--dada_ref_taxonomy unite-fungi=9.0",
                        "--dada_ref_taxonomy unite-fungi=8.3",
                        "--dada_ref_taxonomy unite-fungi=8.2",
                        "--dada_ref_taxonomy zehr-nifh",
                        "--dada_ref_taxonomy zehr-nifh=2.5.0"]

AMPLISEQ_ITS_AMP_ARGS = [
                {"name": "FW_primer", "arg": "--FW_primer ''", "description": "Forward primer sequence - Ignored if skipping cutadapt", "inputMode": "REQUIRED", "notes": {"Optional": "true"} },
                {"name": "RV_primer", "arg": "--RV_primer ''", "description": "Reverse primer sequence - Ignored if skipping cutadapt", "inputMode": "REQUIRED", "notes": {"Optional": "true"} },
                {"name": "metadata", "arg": "--metadata ''", "description": "Path to metadata sheet, when missing most downstream analysis are skipped (barplots, PCoA plots, ...).", "inputMode": "REQUIRED", "notes": {"filePath": "true"} },
                {"name": "Skip Cutadapt", "arg": "--skip_cutadapt", "description": "Skip primer trimming with cutadapt", "inputMode": "INCLUDE_BY_DEFAULT"},
                {"name": "Locus", "arg": "--cut_its none", "description": "Part of ITS region to use for taxonomy assignment: \"none\", \"full\", \"its1\", or \"its2\"", "inputMode": "REQUIRED", "notes": {"Optional": "", "Dropdown": ["--cut_its none", "--cut_its full", "--cut_its its1", "--cut_its its2"]} },
                {"name": "its_partial", "arg": "--its_partial 0", "description": "Cutoff for partial ITS sequences. Only full sequences by default", "inputMode": "REQUIRED"},
#                 {"name": "addsh", "arg": "--addsh", "description": "If ASVs should be assigned to UNITE species hypotheses (SHs). Only relevant for ITS data", "inputMode": "INCLUDE_ON_DEMAND"},
                {"name": "Save Intermediates", "arg": "--save_intermediates", "description": "Save intermediate results such as QIIME2's qza and qzv files", "inputMode": "INCLUDE_ON_DEMAND"},
                {"name": "Illumina Paired End Reads", "arg": "--illumina_pe_its", "description": "If analysing ITS amplicons or any other region with large length variability with Illumina paired end reads", "inputMode": "INCLUDE_ON_DEMAND"},
                {"name": "Illumina NovaSeq Reads", "arg": "--illumina_novaseq", "description": "If data has binned quality scores such as Illumina NovaSeq", "inputMode": "INCLUDE_ON_DEMAND"},
                {"name": "PacBio Reads", "arg": "--pacbio", "description": "If data is single-ended PacBio reads instead of Illumina", "inputMode": "INCLUDE_ON_DEMAND"},
                {"name": "IonTorrent Reads", "arg": "--iontorrent", "description": "If data is single-ended IonTorrent reads instead of Illumina", "inputMode": "INCLUDE_ON_DEMAND"},
                {"name": "Single End Reads", "arg": "--single_end", "description": "If data is single-ended Illumina reads instead of paired-end", "inputMode": "INCLUDE_BY_DEFAULT"},
#                 {"name": "multiple_sequencing_runs", "arg": "--multiple_sequencing_runs", "description": "Multiple sequencing runs?", "inputMode": "INCLUDE_ON_DEMAND"},
#                 {"name": "extension", "arg": "--extension \"/*_R{1,2}.fastq.gz\"", "description": "Extension If using `--input_folder`: naming of sequencing files", "inputMode": "REQUIRED"},
                {"name": "max_ee", "arg": "--max_ee 3", "description": "Maimum number of expected errors per read (>0). DADA2 read filtering option", "inputMode": "REQUIRED"},
                {"name": "min_read_counts", "arg": "--min_read_counts 1", "description": "Set read count threshold for failed samples", "inputMode": "REQUIRED"},
                {"name": "Ignore Empty Input Files", "arg": "--ignore_empty_input_files", "description": "Ignore input files with too few reads", "inputMode": "INCLUDE_BY_DEFAULT"},
                {"name": "Ignore Failed Trimmings", "arg": "--ignore_failed_trimming", "description": "Ignore files with too few reads after trimming", "inputMode": "INCLUDE_BY_DEFAULT"},
#                 {"name": "trunclenf", "arg": "--trunclenf 220", "description": "DADA2 read truncation value for forward strand, set this to 0 for no truncation", "inputMode": "REQUIRED"},
#                 {"name": "trunclenr", "arg": "--trunclenr 190", "description": "DADA2 read truncation value for reverse strand, set this to 0 for no truncation", "inputMode": "REQUIRED"},
                {"name": "trunc_qmin", "arg": "--trunc_qmin 25", "description": "If --trunclenf and --trunclenr are not set, these values will be automatically determined using this median quality score", "inputMode": "REQUIRED"},
#                 {"name": "max_ee", "arg": "--max_ee 2", "description": "DADA2 read filtering option", "inputMode": "REQUIRED"},
                {"name": "min_len", "arg": "--min_len 20", "description": "DADA2 read filtering option", "inputMode": "REQUIRED"},
#                 {"name": "max_len", "arg": "--max_len", "description": "DADA2 read filtering option", "inputMode": "REQUIRED"},
                {"name": "Ignore Failed Filtering", "arg": "--ignore_failed_filtering", "description": "Ignore files with too few reads after quality filtering", "inputMode": "INCLUDE_BY_DEFAULT"},
                {"name": "VSEARCH Cluster", "arg": "--vsearch_cluster", "description": "Post-cluster ASVs with VSEARCH", "inputMode": "INCLUDE_BY_DEFAULT"},
                {"name": "vsearch_cluster_id", "arg": "--vsearch_cluster_id 0.97", "description": "Pairwise Identity value used when post-clustering ASVs if `--vsearch_cluster` option is used (default: 0.97)", "inputMode": "REQUIRED"},
                {"name": "dada_ref_taxonomy", "arg": "--dada_ref_taxonomy unite-alleuk", "description": "Name of supported database, and optionally also version number. https://nf-co.re/ampliseq/2.11.0/parameters/#dada_ref_taxonomy", "inputMode": "REQUIRED", "notes": {"Optional": "", "Dropdown": AMPLISEQ_ITS_DB_DROPDOWN}},
#                 {"name": "dada_ref_tax_custom", "arg": "--dada_ref_tax_custom", "description": "Path to a custom DADA2 reference taxonomy database", "inputMode": "REQUIRED"},
                {"name": "dada_ref_tax_custom_sp ", "arg": "--dada_ref_tax_custom_sp ''", "description": "Path to a custom DADA2 reference taxonomy database for species assignment", "inputMode": "REQUIRED", "notes": {"Optional": "true"}},
#                 {"name": "dada_assign_taxlevels", "arg": "--dada_assign_taxlevels", "description": "Comma separated list of taxonomic levels used in DADA2's assignTaxonomy function", "inputMode": "REQUIRED"},
#                 {"name": "DADA Taxonomy Reverse Complement", "arg": "--dada_taxonomy_rc", "description": "If reverse-complement of each sequences will be also tested for classification", "inputMode": "INCLUDE_ON_DEMAND"},
#                 {"name": "PICRUSt", "arg": "--picrust", "description": "If the functional potential of the bacterial community is predicted", "inputMode": "INCLUDE_ON_DEMAND"},
#                 {"name": "exclude_taxa", "arg": "--exclude_taxa mitochondria,chloroplast", "description": "Comma separated list of unwanted taxa, to skip taxa filtering use \"none\"", "inputMode": "REQUIRED"},
#                 {"name": "min_frequency", "arg": "--min_frequency 1", "description": "Abundance filtering", "inputMode": "REQUIRED"},
#                 {"name": "min_samples", "arg": "--min_samples 1", "description": "Prevalence filtering", "inputMode": "REQUIRED"},
#                 {"name": "skip_fastqc", "arg": "--skip_fastqc", "description": "Skip FastQC", "inputMode": "INCLUDE_ON_DEMAND"},
#                 {"name": "skip_dada_quality", "arg": "--skip_dada_quality", "description": "Skip quality check with DADA2", "inputMode": "INCLUDE_ON_DEMAND"},
                {"name": "Skip Barrnap", "arg": "--skip_barrnap", "description": "Skip annotating SSU matches", "inputMode": "INCLUDE_ON_DEMAND"},
#                 {"name": "skip_qiime", "arg": "--skip_qiime", "description": "Skip all steps that are executed by QIIME2", "inputMode": "INCLUDE_ON_DEMAND"},
#                 {"name": "Skip Qiime Downstream", "arg": "--skip_qiime_downstream", "description": "Skip steps that are executed by QIIME2 except for taxonomic classification", "inputMode": "INCLUDE_ON_DEMAND"},
                {"name": "Skip Alpha Rarefaction", "arg": "--skip_alpha_rarefaction", "description": "Skip alpha rarefaction", "inputMode": "INCLUDE_ON_DEMAND"},
                {"name": "Skip Diversity Indices", "arg": "--skip_diversity_indices", "description": "Skip alpha and beta diversity analysis", "inputMode": "INCLUDE_ON_DEMAND"}
]

AMPLISEQ_16S_AMP_ARGS = [
                {"name": "FW_primer", "arg": "--FW_primer ''", "description": "Forward primer sequence - Ignored if skipping cutadapt", "inputMode": "REQUIRED", "notes": {"Optional": "true"} },
                {"name": "RV_primer", "arg": "--RV_primer ''", "description": "Reverse primer sequence - Ignored if skipping cutadapt", "inputMode": "REQUIRED", "notes": {"Optional": "true"} },
                {"name": "metadata", "arg": "--metadata ''", "description": "Path to metadata sheet, when missing most downstream analysis are skipped (barplots, PCoA plots, ...).", "inputMode": "REQUIRED", "notes": {"filePath": "true"} },
                {"name": "Skip Cutadapt", "arg": "--skip_cutadapt", "description": "Skip primer trimming with cutadapt", "inputMode": "INCLUDE_BY_DEFAULT"},
                {"name": "Save Intermediates", "arg": "--save_intermediates", "description": "Save intermediate results such as QIIME2's qza and qzv files", "inputMode": "INCLUDE_ON_DEMAND"},
#                 {"name": "Illumina NovaSeq Reads", "arg": "--illumina_novaseq", "description": "If data has binned quality scores such as Illumina NovaSeq", "inputMode": "INCLUDE_ON_DEMAND"},
#                 {"name": "PacBio Reads", "arg": "--pacbio", "description": "If data is single-ended PacBio reads instead of Illumina", "inputMode": "INCLUDE_ON_DEMAND"},
#                 {"name": "IonTorrent Reads", "arg": "--iontorrent", "description": "If data is single-ended IonTorrent reads instead of Illumina", "inputMode": "INCLUDE_ON_DEMAND"},
                {"name": "Single End Reads", "arg": "--single_end", "description": "If data is single-ended Illumina reads instead of paired-end", "inputMode": "INCLUDE_ON_DEMAND"},
#                 {"name": "multiple_sequencing_runs", "arg": "--multiple_sequencing_runs", "description": "Multiple sequencing runs?", "inputMode": "INCLUDE_ON_DEMAND"},
                {"name": "extension", "arg": "--extension \"/*_R{1,2}.fastq.gz\"", "description": "Extension If using `--input_folder`: naming of sequencing files", "inputMode": "REQUIRED"},
#                 {"name": "max_ee", "arg": "--max_ee 3", "description": "Maimum number of expected errors per read (>0). DADA2 read filtering option", "inputMode": "REQUIRED"},
                {"name": "min_read_counts", "arg": "--min_read_counts 100", "description": "Set read count threshold for failed samples", "inputMode": "REQUIRED"},
                {"name": "Ignore Empty Input Files", "arg": "--ignore_empty_input_files", "description": "Ignore input files with too few reads", "inputMode": "INCLUDE_BY_DEFAULT"},
                {"name": "Ignore Failed Trimmings", "arg": "--ignore_failed_trimming", "description": "Ignore files with too few reads after trimming", "inputMode": "INCLUDE_BY_DEFAULT"},
                {"name": "trunclenf", "arg": "--trunclenf 220", "description": "DADA2 read truncation value for forward strand, set this to 0 for no truncation", "inputMode": "REQUIRED"},
                {"name": "trunclenr", "arg": "--trunclenr 190", "description": "DADA2 read truncation value for reverse strand, set this to 0 for no truncation", "inputMode": "REQUIRED"},
                {"name": "trunc_qmin", "arg": "--trunc_qmin 25", "description": "If --trunclenf and --trunclenr are not set, these values will be automatically determined using this median quality score", "inputMode": "REQUIRED", "notes": {"Optional": "true", "note": ""}},
                {"name": "trunc_rmin", "arg": "--trunc_rmin 0.75", "description": "Assures that values chosen with --trunc_qmin will retain a fraction of reads", "inputMode": "REQUIRED", "notes": {"Optional": "true", "note": ""}},

#                 {"name": "max_ee", "arg": "--max_ee 2", "description": "DADA2 read filtering option", "inputMode": "REQUIRED"},
#                 {"name": "min_len", "arg": "--min_len 20", "description": "DADA2 read filtering option", "inputMode": "REQUIRED"},
#                 {"name": "max_len", "arg": "--max_len", "description": "DADA2 read filtering option", "inputMode": "REQUIRED"},
                {"name": "Retain Untrimmed", "arg": "--retain_untrimmed", "description": "Cutadapt will retain untrimmed reads", "inputMode": "INCLUDE_ON_DEMAND"},
                {"name": "cutadapt_min_overlap", "arg": "--cutadapt_min_overlap 3", "description": "Sets the minimum overlap for valid matches of primer sequences with reads for cutadapt (-O)", "inputMode": "REQUIRED", "notes": {"Optional": "true"} },
                {"name": "cutadapt_max_error_rate", "arg": "--cutadapt_max_error_rate 0.1", "description": "Sets the maximum error rate for valid matches of primer sequences with reads for cutadapt (-e)", "inputMode": "REQUIRED", "notes": {"Optional": "true"} },
                {"name": "Ignore Failed Filtering", "arg": "--ignore_failed_filtering", "description": "Ignore files with too few reads after quality filtering", "inputMode": "INCLUDE_BY_DEFAULT"},
                
                {"name": "sample_inference", "arg": "--sample_inference independent", "description": "Mode of sample inference: \"independent\", \"pooled\" or \"pseudo\"", "inputMode": "REQUIRED", "notes": {"Dropdown": ["--sample_inference independent","--sample_inference pooled","--sample_inference pseudo"]}},
    
                {"name": "VSEARCH Cluster", "arg": "--vsearch_cluster", "description": "Post-cluster ASVs with VSEARCH", "inputMode": "INCLUDE_BY_DEFAULT"},
                {"name": "vsearch_cluster_id", "arg": "--vsearch_cluster_id 0.98", "description": "Pairwise Identity value used when post-clustering ASVs if `--vsearch_cluster` option is used (default: 0.97)", "inputMode": "REQUIRED"},
                
                {"name": "dada_ref_taxonomy", "arg": "--dada_ref_taxonomy silva=138", "description": "Name of supported database, and optionally also version number. https://nf-co.re/ampliseq/2.11.0/parameters/#dada_ref_taxonomy", "inputMode": "REQUIRED", "notes": {"Optional": "", "Dropdown": AMPLISEQ_DB_DROPDOWN}},
                {"name": "dada_ref_tax_custom", "arg": "--dada_ref_tax_custom ''", "description": "Path to a custom DADA2 reference taxonomy database", "inputMode": "REQUIRED", "notes": {"Optional": "true"} },
                {"name": "dada_ref_tax_custom_sp ", "arg": "--dada_ref_tax_custom_sp ''", "description": "Path to a custom DADA2 reference taxonomy database for species assignment", "inputMode": "REQUIRED", "notes": {"Optional": "true"} },
                {"name": "dada_assign_taxlevels", "arg": "--dada_assign_taxlevels ''", "description": "Comma separated list of taxonomic levels used in DADA2's assignTaxonomy function", "inputMode": "REQUIRED", "notes": {"Optional": "true"} },

                {"name": "DADA Taxonomy Reverse Complement", "arg": "--dada_taxonomy_rc", "description": "If reverse-complement of each sequences will be also tested for classification", "inputMode": "INCLUDE_ON_DEMAND"},
                {"name": "PICRUSt", "arg": "--picrust", "description": "If the functional potential of the bacterial community is predicted", "inputMode": "INCLUDE_BY_DEFAULT"},
                {"name": "exclude_taxa", "arg": "--exclude_taxa 'mitochondria,chloroplast,unknown'", "description": "Comma separated list of unwanted taxa, to skip taxa filtering use \"none\"", "inputMode": "REQUIRED", "notes": {"Optional": "true"} },
                {"name": "min_frequency", "arg": "--min_frequency 1", "description": "Abundance filtering", "inputMode": "REQUIRED"},
                {"name": "min_samples", "arg": "--min_samples 1", "description": "Prevalence filtering", "inputMode": "REQUIRED"},

                {"name": "diversity_rarefaction_depth", "arg": "--diversity_rarefaction_depth 10000", "description": "Minimum rarefaction depth for diversity analysis", "inputMode": "REQUIRED", "notes": {"Optional": "true", "Info": "..."}},

#                 {"name": "skip_fastqc", "arg": "--skip_fastqc", "description": "Skip FastQC", "inputMode": "INCLUDE_ON_DEMAND"},
#                 {"name": "skip_dada_quality", "arg": "--skip_dada_quality", "description": "Skip quality check with DADA2", "inputMode": "INCLUDE_ON_DEMAND"},
                {"name": "Skip Barrnap", "arg": "--skip_barrnap", "description": "Skip annotating SSU matches", "inputMode": "INCLUDE_BY_DEFAULT"},
#                 {"name": "skip_qiime", "arg": "--skip_qiime", "description": "Skip all steps that are executed by QIIME2", "inputMode": "INCLUDE_ON_DEMAND"},
#                 {"name": "Skip Qiime Downstream", "arg": "--skip_qiime_downstream", "description": "Skip steps that are executed by QIIME2 except for taxonomic classification", "inputMode": "INCLUDE_ON_DEMAND"},
                {"name": "Skip Alpha Rarefaction", "arg": "--skip_alpha_rarefaction", "description": "Skip alpha rarefaction", "inputMode": "INCLUDE_ON_DEMAND"},
                {"name": "Skip Diversity Indices", "arg": "--skip_diversity_indices", "description": "Skip alpha and beta diversity analysis", "inputMode": "INCLUDE_ON_DEMAND"}
]


"""
Every single argument that is used in the nf-core/ampliseq pipeline is defined here.
"""
AMPLISEQ_AMP_ARGS = [
    # input_output_options
    # Main arguments: 
    {"name": "input", "arg": "--input", "description": "Path to tab-separated sample sheet", "inputMode": "REQUIRED"},
    {"name": "input_fasta", "arg": "--input_fasta", "description": "Path to ASV/OTU fasta file", "inputMode": "REQUIRED"},
    {"name": "input_folder", "arg": "--input_folder", "description": "Path to folder containing zipped FastQ files", "inputMode": "REQUIRED"},
    {"name": "FW_primer", "arg": "--FW_primer GTGYCAGCMGCCGCGGTAA", "description": "Forward primer sequence", "inputMode": "REQUIRED"},
    {"name": "RV_primer", "arg": "--RV_primer GGACTACNVGGGTWTCTAAT", "description": "Reverse primer sequence", "inputMode": "REQUIRED"},
    {"name": "metadata", "arg": "--metadata ''", "description": "Path to metadata sheet, when missing most downstream analysis are skipped (barplots, PCoA plots, ...).", "inputMode": "REQUIRED", "notes": {"filePath": "true"} },
    {"name": "multiregion", "arg": "--multiregion", "description": "Path to multi-region definition sheet, for multi-region analysis with Sidle", "inputMode": "REQUIRED"},
    {"name": "outdir", "arg": "--outdir", "description": "The output directory where the results will be saved", "inputMode": "REQUIRED"},
    {"name": "save_intermediates", "arg": "--save_intermediates", "description": "Save intermediate results such as QIIME2's qza and qzv files", "inputMode": "REQUIRED"},
    {"name": "email", "arg": "--email", "description": "Email address for completion summary", "inputMode": "REQUIRED"},

    # sequencing_input
    # Sequencing input: 
    {"name": "illumina_novaseq", "arg": "--illumina_novaseq", "description": "If data has binned quality scores such as Illumina NovaSeq", "inputMode": "REQUIRED"},
    {"name": "pacbio", "arg": "--pacbio", "description": "If data is single-ended PacBio reads instead of Illumina", "inputMode": "REQUIRED"},
    {"name": "iontorrent", "arg": "--iontorrent", "description": "If data is single-ended IonTorrent reads instead of Illumina", "inputMode": "REQUIRED"},
    {"name": "single_end", "arg": "--single_end", "description": "If data is single-ended Illumina reads instead of paired-end", "inputMode": "REQUIRED"},
    {"name": "illumina_pe_its", "arg": "--illumina_pe_its", "description": "If analysing ITS amplicons or any other region with large length variability with Illumina paired end reads", "inputMode": "REQUIRED"},
    {"name": "multiple_sequencing_runs", "arg": "--multiple_sequencing_runs", "description": "If using `--input_folder`: samples were sequenced in multiple sequencing runs", "inputMode": "REQUIRED"},
    {"name": "extension", "arg": "--extension /*_R{1,2}_001.fastq.gz", "description": "Extension If using `--input_folder`: naming of sequencing files", "inputMode": "REQUIRED"},
    {"name": "min_read_counts", "arg": "--min_read_counts 1", "description": "Set read count threshold for failed samples", "inputMode": "REQUIRED"},
    {"name": "ignore_empty_input_files", "arg": "--ignore_empty_input_files", "description": "Ignore input files with too few reads", "inputMode": "REQUIRED"},

    # primer_removal
    # Primer removal: Spurious sequences sometimes lack primer sequences and primers introduce errors that can be removed in that step
    {"name": "retain_untrimmed", "arg": "--retain_untrimmed", "description": "Cutadapt will retain untrimmed reads", "inputMode": "REQUIRED"},
    {"name": "cutadapt_min_overlap", "arg": "--cutadapt_min_overlap 3", "description": "Sets the minimum overlap for valid matches of primer sequences with reads for cutadapt (-O)", "inputMode": "REQUIRED"},
    {"name": "cutadapt_max_error_rate", "arg": "--cutadapt_max_error_rate 0.1", "description": "Sets the maximum error rate for valid matches of primer sequences with reads for cutadapt (-e)", "inputMode": "REQUIRED"},
    {"name": "double_primer", "arg": "--double_primer", "description": "Cutadapt will be run twice to ensure removal of potential double primers", "inputMode": "REQUIRED"},
    {"name": "ignore_failed_trimming", "arg": "--ignore_failed_trimming", "description": "Ignore files with too few reads after trimming", "inputMode": "REQUIRED"},

    # read_trimming_and_quality_filtering
    # Read trimming and quality filtering: Read trimming and quality filtering is supposed to reduce spurious results and aid error correction
    {"name": "trunclenf", "arg": "--trunclenf", "description": "DADA2 read truncation value for forward strand, set this to 0 for no truncation", "inputMode": "REQUIRED"},
    {"name": "trunclenr", "arg": "--trunclenr", "description": "DADA2 read truncation value for reverse strand, set this to 0 for no truncation", "inputMode": "REQUIRED"},
    {"name": "trunc_qmin", "arg": "--trunc_qmin 25", "description": "If --trunclenf and --trunclenr are not set, these values will be automatically determined using this median quality score", "inputMode": "REQUIRED"},
    {"name": "trunc_rmin", "arg": "--trunc_rmin 0.75", "description": "Assures that values chosen with --trunc_qmin will retain a fraction of reads", "inputMode": "REQUIRED"},
    {"name": "max_ee", "arg": "--max_ee 2", "description": "DADA2 read filtering option", "inputMode": "REQUIRED"},
    {"name": "min_len", "arg": "--min_len 50", "description": "DADA2 read filtering option", "inputMode": "REQUIRED"},
    {"name": "max_len", "arg": "--max_len", "description": "DADA2 read filtering option", "inputMode": "REQUIRED"},
    {"name": "ignore_failed_filtering", "arg": "--ignore_failed_filtering", "description": "Ignore files with too few reads after quality filtering", "inputMode": "REQUIRED"},

    # amplicon_sequence_variants_asv_calculation
    # Amplicon Sequence Variants (ASV) calculation: 
    {"name": "sample_inference", "arg": "--sample_inference independent", "description": "Mode of sample inference: \"independent\", \"pooled\" or \"pseudo\"", "inputMode": "REQUIRED"},
    {"name": "concatenate_reads", "arg": "--concatenate_reads", "description": "Not recommended: When paired end reads are not sufficiently overlapping for merging", "inputMode": "REQUIRED"},

    # asv_post_processing
    # ASV post processing: ASV post-processing takes place after ASV computation but before taxonomic assignment, it will affect all downstream processes
    {"name": "vsearch_cluster", "arg": "--vsearch_cluster", "description": "Post-cluster ASVs with VSEARCH", "inputMode": "REQUIRED"},
    {"name": "vsearch_cluster_id", "arg": "--vsearch_cluster_id 0.97", "description": "Pairwise Identity value used when post-clustering ASVs if `--vsearch_cluster` option is used (default: 0.97)", "inputMode": "REQUIRED"},
    {"name": "filter_ssu", "arg": "--filter_ssu", "description": "Enable SSU filtering. Comma separated list of kingdoms (domains) in Barrnap", "inputMode": "REQUIRED"},
    {"name": "min_len_asv", "arg": "--min_len_asv", "description": "Minimal ASV length", "inputMode": "REQUIRED"},
    {"name": "max_len_asv", "arg": "--max_len_asv", "description": "Maximum ASV length", "inputMode": "REQUIRED"},
    {"name": "filter_codons", "arg": "--filter_codons", "description": "Filter ASVs based on codon usage", "inputMode": "REQUIRED"},
    {"name": "orf_start", "arg": "--orf_start 1", "description": "Starting position of codon tripletts", "inputMode": "REQUIRED"},
    {"name": "orf_end", "arg": "--orf_end", "description": "Ending position of codon tripletts", "inputMode": "REQUIRED"},
    {"name": "stop_codons", "arg": "--stop_codons TAA,TAG", "description": "Define stop codons", "inputMode": "REQUIRED"},

    # taxonomic_database
    # Taxonomic database: Choose a method and database for taxonomic assignments to single-region amplicons
    {"name": "dada_ref_taxonomy", "arg": "--dada_ref_taxonomy silva=138", "description": "Name of supported database, and optionally also version number", "inputMode": "REQUIRED"},
    {"name": "dada_ref_tax_custom", "arg": "--dada_ref_tax_custom", "description": "Path to a custom DADA2 reference taxonomy database", "inputMode": "REQUIRED"},
    {"name": "dada_ref_tax_custom_sp", "arg": "--dada_ref_tax_custom_sp", "description": "Path to a custom DADA2 reference taxonomy database for species assignment", "inputMode": "REQUIRED"},
    {"name": "dada_assign_taxlevels", "arg": "--dada_assign_taxlevels", "description": "Comma separated list of taxonomic levels used in DADA2's assignTaxonomy function", "inputMode": "REQUIRED"},
    {"name": "cut_dada_ref_taxonomy", "arg": "--cut_dada_ref_taxonomy", "description": "If the expected amplified sequences are extracted from the DADA2 reference taxonomy database", "inputMode": "REQUIRED"},
    {"name": "dada_addspecies_allowmultiple", "arg": "--dada_addspecies_allowmultiple", "description": "If multiple exact matches against different species are returned", "inputMode": "REQUIRED"},
    {"name": "dada_taxonomy_rc", "arg": "--dada_taxonomy_rc", "description": "If reverse-complement of each sequences will be also tested for classification", "inputMode": "REQUIRED"},
    {"name": "pplace_tree", "arg": "--pplace_tree", "description": "Newick file with reference phylogenetic tree. Requires also `--pplace_aln` and `--pplace_model`", "inputMode": "REQUIRED"},
    {"name": "pplace_aln", "arg": "--pplace_aln", "description": "File with reference sequences. Requires also `--pplace_tree` and `--pplace_model`", "inputMode": "REQUIRED"},
    {"name": "pplace_model", "arg": "--pplace_model", "description": "Phylogenetic model to use in placement, e.g. 'LG+F' or 'GTR+I+F'. Requires also `--pplace_tree` and `--pplace_aln`", "inputMode": "REQUIRED"},
    {"name": "pplace_alnmethod", "arg": "--pplace_alnmethod hmmer", "description": "Method used for alignment, \"hmmer\" or \"mafft\"", "inputMode": "REQUIRED"},
    {"name": "pplace_taxonomy", "arg": "--pplace_taxonomy", "description": "Tab-separated file with taxonomy assignments of reference sequences", "inputMode": "REQUIRED"},
    {"name": "pplace_name", "arg": "--pplace_name", "description": "A name for the run", "inputMode": "REQUIRED"},
    {"name": "qiime_ref_taxonomy", "arg": "--qiime_ref_taxonomy", "description": "Name of supported database, and optionally also version number", "inputMode": "REQUIRED"},
    {"name": "qiime_ref_tax_custom", "arg": "--qiime_ref_tax_custom", "description": "Path to files of a custom QIIME2 reference taxonomy database (tarball, or two comma-separated files)", "inputMode": "REQUIRED"},
    {"name": "classifier", "arg": "--classifier", "description": "Path to QIIME2 trained classifier file (typically *-classifier.qza)", "inputMode": "REQUIRED"},
    {"name": "kraken2_ref_taxonomy", "arg": "--kraken2_ref_taxonomy", "description": "Name of supported database, and optionally also version number", "inputMode": "REQUIRED"},
    {"name": "kraken2_ref_tax_custom", "arg": "--kraken2_ref_tax_custom", "description": "Path to a custom Kraken2 reference taxonomy database (*.tar.gz|*.tgz archive or folder)", "inputMode": "REQUIRED"},
    {"name": "kraken2_assign_taxlevels", "arg": "--kraken2_assign_taxlevels", "description": "Comma separated list of taxonomic levels used in Kraken2. Will overwrite default values", "inputMode": "REQUIRED"},
    {"name": "kraken2_confidence", "arg": "--kraken2_confidence 0.0", "description": "Confidence score threshold for taxonomic classification", "inputMode": "REQUIRED"},
    {"name": "sintax_ref_taxonomy", "arg": "--sintax_ref_taxonomy", "description": "Name of supported database, and optionally also version number", "inputMode": "REQUIRED"},
    {"name": "addsh", "arg": "--addsh", "description": "If ASVs should be assigned to UNITE species hypotheses (SHs). Only relevant for ITS data", "inputMode": "REQUIRED"},
    {"name": "cut_its", "arg": "--cut_its none", "description": "Part of ITS region to use for taxonomy assignment: \"full\", \"its1\", or \"its2\"", "inputMode": "REQUIRED"},
    {"name": "its_partial", "arg": "--its_partial 0", "description": "Cutoff for partial ITS sequences. Only full sequences by default", "inputMode": "REQUIRED"},

    # multiregion_taxonomic_database
    # Multi-region taxonomic database: Choose database for taxonomic assignments with multi-region amplicons using SIDLE
    {"name": "sidle_ref_taxonomy", "arg": "--sidle_ref_taxonomy", "description": "Name of supported database, and optionally also version number", "inputMode": "REQUIRED"},
    {"name": "sidle_ref_tax_custom", "arg": "--sidle_ref_tax_custom", "description": "Comma separated paths to three files: reference taxonomy sequences (*.fasta), reference taxonomy strings (*.txt)", "inputMode": "REQUIRED"},
    {"name": "sidle_ref_tree_custom", "arg": "--sidle_ref_tree_custom", "description": "Path to SIDLE reference taxonomy tree (*.qza)", "inputMode": "REQUIRED"},

    # asv_filtering
    # ASV filtering: Filtering by taxonomy or abundance will affect all downstream analysis
    {"name": "exclude_taxa", "arg": "--exclude_taxa mitochondria,chloroplast", "description": "Comma separated list of unwanted taxa, to skip taxa filtering use \"none\"", "inputMode": "REQUIRED"},
    {"name": "min_frequency", "arg": "--min_frequency 1", "description": "Abundance filtering", "inputMode": "REQUIRED"},
    {"name": "min_samples", "arg": "--min_samples 1", "description": "Prevalence filtering", "inputMode": "REQUIRED"},

    # downstream_analysis
    # Downstream analysis: Metadata is used here to visualize data either for quality control or publication ready figures
    {"name": "metadata_category", "arg": "--metadata_category", "description": "Comma separated list of metadata column headers for statistics", "inputMode": "REQUIRED"},
    {"name": "metadata_category_barplot", "arg": "--metadata_category_barplot", "description": "Comma separated list of metadata column headers for plotting average relative abundance barplots", "inputMode": "REQUIRED"},
    {"name": "qiime_adonis_formula", "arg": "--qiime_adonis_formula", "description": "Formula for QIIME2 ADONIS metadata feature importance test for beta diversity distances", "inputMode": "REQUIRED"},
    {"name": "picrust", "arg": "--picrust", "description": "If the functional potential of the bacterial community is predicted", "inputMode": "REQUIRED"},
    {"name": "sbdiexport", "arg": "--sbdiexport", "description": "If data should be exported in SBDI (Swedish biodiversity infrastructure) Excel format", "inputMode": "REQUIRED"},
    {"name": "diversity_rarefaction_depth", "arg": "--diversity_rarefaction_depth 500", "description": "Minimum rarefaction depth for diversity analysis", "inputMode": "REQUIRED"},
    {"name": "tax_agglom_min", "arg": "--tax_agglom_min 2", "description": "Minimum taxonomy agglomeration level for taxonomic classifications", "inputMode": "REQUIRED"},
    {"name": "tax_agglom_max", "arg": "--tax_agglom_max 6", "description": "Maximum taxonomy agglomeration level for taxonomic classifications", "inputMode": "REQUIRED"},

    # differential_abundance_analysis
    # Differential abundance analysis: Differential abundance analysis relies on provided metadata
    {"name": "ancom_sample_min_count", "arg": "--ancom_sample_min_count 1", "description": "Minimum sample counts to retain a sample for ANCOM analysis", "inputMode": "REQUIRED"},
    {"name": "ancom", "arg": "--ancom", "description": "Perform differential abundance analysis with ANCOM", "inputMode": "REQUIRED"},
    {"name": "ancombc", "arg": "--ancombc", "description": "Perform differential abundance analysis with ANCOMBC", "inputMode": "REQUIRED"},
    {"name": "ancombc_formula", "arg": "--ancombc_formula", "description": "Formula to perform differential abundance analysis with ANCOMBC", "inputMode": "REQUIRED"},
    {"name": "ancombc_formula_reflvl", "arg": "--ancombc_formula_reflvl", "description": "Reference level for `--ancombc_formula`", "inputMode": "REQUIRED"},
    {"name": "ancombc_effect_size", "arg": "--ancombc_effect_size 1", "description": "Effect size threshold for differential abundance barplot for `--ancombc` and `--ancombc_formula`", "inputMode": "REQUIRED"},
    {"name": "ancombc_significance", "arg": "--ancombc_significance 0.05", "description": "Significance threshold for differential abundance barplot for `--ancombc` and `--ancombc_formula`", "inputMode": "REQUIRED"},

    # pipeline_report
    # Pipeline summary report: Customization of the pipeline report
    {"name": "report_template", "arg": "--report_template ${projectDir}/assets/report_template.Rmd", "description": "Path to Markdown file (Rmd)", "inputMode": "REQUIRED"},
    {"name": "report_css", "arg": "--report_css ${projectDir}/assets/nf-core_style.css", "description": "Path to style file (css)", "inputMode": "REQUIRED"},
    {"name": "report_logo", "arg": "--report_logo ${projectDir}/assets/nf-core-ampliseq_logo_light_long.png", "description": "Path to logo file (png)", "inputMode": "REQUIRED"},
    {"name": "report_title", "arg": "--report_title 'Summary of analysis results'", "description": "String used as report title", "inputMode": "REQUIRED"},
    {"name": "report_abstract", "arg": "--report_abstract", "description": "Path to Markdown file (md) that replaces the 'Abstract' section", "inputMode": "REQUIRED"},

    # skipping_specific_steps
    # Skipping specific steps: 
    {"name": "skip_fastqc", "arg": "--skip_fastqc", "description": "Skip FastQC", "inputMode": "REQUIRED"},
    {"name": "skip_cutadapt", "arg": "--skip_cutadapt", "description": "Skip primer trimming with cutadapt", "inputMode": "REQUIRED"},
    {"name": "skip_dada_quality", "arg": "--skip_dada_quality", "description": "Skip quality check with DADA2", "inputMode": "REQUIRED"},
    {"name": "skip_barrnap", "arg": "--skip_barrnap", "description": "Skip annotating SSU matches", "inputMode": "REQUIRED"},
    {"name": "skip_qiime", "arg": "--skip_qiime", "description": "Skip all steps that are executed by QIIME2", "inputMode": "REQUIRED"},
    {"name": "skip_qiime_downstream", "arg": "--skip_qiime_downstream", "description": "Skip steps that are executed by QIIME2 except for taxonomic classification", "inputMode": "REQUIRED"},
    {"name": "skip_taxonomy", "arg": "--skip_taxonomy", "description": "Skip taxonomic classification", "inputMode": "REQUIRED"},
    {"name": "skip_dada_taxonomy", "arg": "--skip_dada_taxonomy", "description": "Skip taxonomic classification with DADA2", "inputMode": "REQUIRED"},
    {"name": "skip_dada_addspecies", "arg": "--skip_dada_addspecies", "description": "Skip species level when using DADA2 for taxonomic classification", "inputMode": "REQUIRED"},
    {"name": "skip_barplot", "arg": "--skip_barplot", "description": "Skip producing barplot", "inputMode": "REQUIRED"},
    {"name": "skip_abundance_tables", "arg": "--skip_abundance_tables", "description": "Skip producing any relative abundance tables", "inputMode": "REQUIRED"},
    {"name": "skip_alpha_rarefaction", "arg": "--skip_alpha_rarefaction", "description": "Skip alpha rarefaction", "inputMode": "REQUIRED"},
    {"name": "skip_diversity_indices", "arg": "--skip_diversity_indices", "description": "Skip alpha and beta diversity analysis", "inputMode": "REQUIRED"},
    {"name": "skip_multiqc", "arg": "--skip_multiqc", "description": "Skip MultiQC reporting", "inputMode": "REQUIRED"},
    {"name": "skip_report", "arg": "--skip_report", "description": "Skip Markdown summary report", "inputMode": "REQUIRED"},

    # generic_options
    # Generic options: Less common options for the pipeline, typically set in a config file.
    {"name": "seed", "arg": "--seed 100", "description": "Specifies the random seed", "inputMode": "REQUIRED"},
    {"name": "help", "arg": "--help", "description": "Display help text", "inputMode": "REQUIRED"},
    {"name": "version", "arg": "--version", "description": "Display version and exit", "inputMode": "REQUIRED"},
    {"name": "publish_dir_mode", "arg": "--publish_dir_mode copy", "description": "Method used to save pipeline results to output directory", "inputMode": "REQUIRED"},
    {"name": "email_on_fail", "arg": "--email_on_fail", "description": "Email address for completion summary, only when pipeline fails", "inputMode": "REQUIRED"},
    {"name": "plaintext_email", "arg": "--plaintext_email", "description": "Send plain-text email instead of HTML", "inputMode": "REQUIRED"},
    {"name": "max_multiqc_email_size", "arg": "--max_multiqc_email_size 25.MB", "description": "File size limit when attaching MultiQC reports to summary emails", "inputMode": "REQUIRED"},
    {"name": "monochrome_logs", "arg": "--monochrome_logs", "description": "Do not use coloured log outputs", "inputMode": "REQUIRED"},
    {"name": "hook_url", "arg": "--hook_url", "description": "Incoming hook URL for messaging service", "inputMode": "REQUIRED"},
    {"name": "multiqc_config", "arg": "--multiqc_config", "description": "Custom config file to supply to MultiQC", "inputMode": "REQUIRED"},
    {"name": "multiqc_logo", "arg": "--multiqc_logo", "description": "Custom logo file to supply to MultiQC", "inputMode": "REQUIRED"},
    {"name": "multiqc_methods_description", "arg": "--multiqc_methods_description", "description": "Custom MultiQC yaml file containing HTML including a methods description", "inputMode": "REQUIRED"},
    {"name": "validate_params", "arg": "--validate_params true", "description": "Boolean whether to validate parameters against the schema at runtime", "inputMode": "REQUIRED"},
    {"name": "validationShowHiddenParams", "arg": "--validationShowHiddenParams", "description": "Show all params when using `--help`", "inputMode": "REQUIRED"},
    {"name": "validationFailUnrecognisedParams", "arg": "--validationFailUnrecognisedParams", "description": "Validation of parameters fails when an unrecognised parameter is found", "inputMode": "REQUIRED"},
    {"name": "validationLenientMode", "arg": "--validationLenientMode", "description": "Validation of parameters in lenient more", "inputMode": "REQUIRED"},
    {"name": "pipelines_testdata_base_path", "arg": "--pipelines_testdata_base_path https://raw.githubusercontent.com/nf-core/test-datasets/", "description": "Base URL or local path to location of pipeline test dataset files", "inputMode": "REQUIRED"},

    # max_job_request_options
    # Max job request options: Set the top limit for requested resources for any single job.
    {"name": "max_cpus", "arg": "--max_cpus 16", "description": "Maximum number of CPUs that can be requested for any single job", "inputMode": "REQUIRED"},
    {"name": "max_memory", "arg": "--max_memory 128.GB", "description": "Maximum amount of memory that can be requested for any single job", "inputMode": "REQUIRED"},
    {"name": "max_time", "arg": "--max_time 240.h", "description": "Maximum amount of time that can be requested for any single job", "inputMode": "REQUIRED"},

    # institutional_config_options
    # Institutional config options: Parameters used to describe centralised config profiles. These should not be edited.
    {"name": "custom_config_version", "arg": "--custom_config_version master", "description": "Git commit id for Institutional configs", "inputMode": "REQUIRED"},
    {"name": "custom_config_base", "arg": "--custom_config_base https://raw.githubusercontent.com/nf-core/configs/master", "description": "Base directory for Institutional configs", "inputMode": "REQUIRED"},
    {"name": "config_profile_name", "arg": "--config_profile_name", "description": "Institutional config name", "inputMode": "REQUIRED"},
    {"name": "config_profile_description", "arg": "--config_profile_description", "description": "Institutional config description", "inputMode": "REQUIRED"},
    {"name": "config_profile_contact", "arg": "--config_profile_contact", "description": "Institutional config contact information", "inputMode": "REQUIRED"},
    {"name": "config_profile_url", "arg": "--config_profile_url", "description": "Institutional config URL link", "inputMode": "REQUIRED"},
    {"name": "multiqc_title", "arg": "--multiqc_title", "description": "MultiQC report title", "inputMode": "REQUIRED"}
]
