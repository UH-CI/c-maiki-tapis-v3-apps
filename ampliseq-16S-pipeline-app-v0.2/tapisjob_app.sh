#!/usr/bin/env bash

source ~/.bashrc
module load lang/Java/17

export NXF_HOME=$PWD/ampliseq-16S-pipeline-app-v0.2/.nextflow
export NXF_SINGULARITY_CACHEDIR=/mnt/lustre/koa/lab/cmaiki_group/cmaiki_v2_apps/singularity_images.cache

# Cleanup function that runs on script exit
cleanup() {
    # ONLY FOR DEV. REMOVE IN PROD
    # Change file permissions to enable deletion by other users
    chmod -R g+w $PWD 2>/dev/null || true
    
}

# Set trap to run cleanup on script exit (normal or error)
trap cleanup EXIT

args=(
    -r 2.14.0
    -c "conf/hpc.config"
    --outdir "./ampliseq_16S_pipeline_outputs"
)

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        # --input_fasta) input_fasta="$2"; shift ;;
        --FW_primer) FW_primer="$2"; shift ;;
        --RV_primer) RV_primer="$2"; shift ;;
        --metadata) 
            if [[ "$2" == tapis://cmaiki-v2-dev-koa-hpc/* ]]; then
                metadata="${2#tapis://cmaiki-v2-dev-koa-hpc}"
            else
                metadata="$2"
            fi
            shift ;;
        --skip_cutadapt) skip_cutadapt=1 ;;
        --save_intermediates) save_intermediates=1 ;;
        --single_end) single_end=1 ;;
        --extension) extension="$2"; shift ;;
        --min_read_counts) min_read_counts="$2"; shift ;;
        --ignore_empty_input_files) ignore_empty_input_files=1 ;;
        --ignore_failed_trimming) ignore_failed_trimming=1 ;;
        --trunclenf) trunclenf="$2"; shift ;;
        --trunclenr) trunclenr="$2"; shift ;;
        --trunc_qmin) trunc_qmin="$2"; shift ;;
        --trunc_rmin) trunc_rmin="$2"; shift ;;
        # --max_ee) max_ee="$2"; shift ;;
        # --min_len) min_len="$2"; shift ;;
        --retain_untrimmed) retain_untrimmed=1 ;;
        --cutadapt_min_overlap) cutadapt_min_overlap="$2"; shift ;;
        --cutadapt_max_error_rate) cutadapt_max_error_rate="$2"; shift ;;
        --sample_inference) sample_inference="$2"; shift ;;
        --ignore_failed_filtering) ignore_failed_filtering=1 ;;
        --vsearch_cluster) vsearch_cluster=1 ;;
        --vsearch_cluster_id) vsearch_cluster_id="$2"; shift ;;
        --dada_ref_taxonomy) dada_ref_taxonomy="$2"; shift ;;
        --dada_ref_tax_custom) dada_ref_tax_custom="$2"; shift ;;
        --dada_ref_tax_custom_sp) dada_ref_tax_custom_sp="$2"; shift ;;
        --dada_assign_taxlevels) dada_assign_taxlevels="$2"; shift ;;
        --dada_taxonomy_rc) dada_taxonomy_rc=1 ;;
        --picrust) picrust=1 ;;
        --exclude_taxa) exclude_taxa="$2"; shift ;;
        --min_frequency) min_frequency="$2"; shift ;;
        --min_samples) min_samples="$2"; shift ;;
        --diversity_rarefaction_depth) diversity_rarefaction_depth="$2"; shift ;;
        # --skip_fastqc) skip_fastqc=1 ;;
        # --skip_dada_quality) skip_dada_quality=1 ;;
        --skip_barrnap) skip_barrnap=1 ;;
        # --skip_qiime) skip_qiime=1 ;;
        # --skip_qiime_downstream) skip_qiime_downstream=1 ;;
        # --skip_taxonomy) skip_taxonomy=1 ;;
        # --skip_dada_taxonomy) skip_dada_taxonomy=1 ;;
        --skip_alpha_rarefaction) skip_alpha_rarefaction=1 ;;
        --skip_diversity_indices) skip_diversity_indices=1 ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [[ "$illumina_pe_its" -eq 1 || "$illumina_novaseq" -eq 1 ]]; then
    [[ "$illumina_pe_its" -eq 1 ]] && args+=(--illumina_pe_its)
    [[ "$illumina_novaseq" -eq 1 ]] && args+=(--illumina_novaseq)
    extension="/*_R{1,2}.fastq.gz"
elif [[ "$pacbio" -eq 1 || "$iontorrent" -eq 1 || "$single_end" -eq 1 ]]; then
    [[ "$pacbio" -eq 1 ]] && args+=(--pacbio)
    [[ "$iontorrent" -eq 1 ]] && args+=(--iontorrent)
    [[ "$single_end" -eq 1 ]] && args+=(--single_end)
    extension="/*_R1.fastq.gz"
fi

# Check for tar files in reads
reads_no_ext=$(basename "${reads}" .tar)
if [ "${reads_no_ext}" != "${reads}" ]; then
    # Set path to reads dir within untarred file
    read_path="${PWD}/${reads_no_ext}/reads"
    # Check if the directory exists, extract tar file if not
    if [ ! -d "$read_path" ]; then
        # Create directory if it doesn't exist
        mkdir -p "$read_path"
        # Extract tar file to reads dir
        tar -xf "${PWD}/${reads}" -C "$read_path"
    fi
else
    read_path="${PWD}/reads"
fi

args+=(
    --input_folder "${read_path}"
    --extension "${extension}"
)

# Conditionally add parameters if they are not empty
[[ -n "$FW_primer" ]] && args+=(--FW_primer "$FW_primer")
[[ -n "$RV_primer" ]] && args+=(--RV_primer "$RV_primer")

[[ -n "$metadata" ]] && args+=(--metadata "$metadata")
# [[ -n "$extension" ]] && args+=(--extension "$extension")
[[ -n "$min_read_counts" ]] && args+=(--min_read_counts "$min_read_counts")
[[ -n "$trunclenf" ]] && args+=(--trunclenf "$trunclenf")
[[ -n "$trunclenr" ]] && args+=(--trunclenr "$trunclenr")
[[ -n "$trunc_qmin" ]] && args+=(--trunc_qmin "$trunc_qmin")
[[ -n "$trunc_rmin" ]] && args+=(--trunc_rmin "$trunc_rmin")
[[ -n "$max_ee" ]] && args+=(--max_ee "$max_ee")
[[ -n "$min_len" ]] && args+=(--min_len "$min_len")

[[ -n "$sample_inference" ]] && args+=(--sample_inference "$sample_inference")

[[ -n "$cutadapt_min_overlap" ]] && args+=(--cutadapt_min_overlap "$cutadapt_min_overlap")
[[ -n "$cutadapt_max_error_rate" ]] && args+=(--cutadapt_max_error_rate "$cutadapt_max_error_rate")

[[ -n "$vsearch_cluster_id" ]] && args+=(--vsearch_cluster_id "$vsearch_cluster_id")

# Hopefully temporary while ampliseq is unable to retrieve Silva files 
if [[ "$dada_ref_taxonomy" == "silva=138" ]]; then
    # Use Silva files packaged with app --dada_ref_taxonomy
    args+=(--dada_ref_tax_custom_sp "./dbs/silva_species_assignment_v138.1.fa.gz")
    args+=(--dada_ref_tax_custom "./dbs/silva_nr99_v138.1_wSpecies_train_set.fa.gz")
else
    args+=(--dada_ref_taxonomy "$dada_ref_taxonomy")
fi

[[ -n "$dada_ref_tax_custom" && "$dada_ref_taxonomy" != "silva=138" ]] && args+=(--dada_ref_tax_custom "$dada_ref_tax_custom")
[[ -n "$dada_ref_tax_custom_sp" && "$dada_ref_taxonomy" != "silva=138" ]] && args+=(--dada_ref_tax_custom_sp "$dada_ref_tax_custom_sp")

# Typical arg handling for dada_ref_taxonomy files when ampliseq is working as expected:
# Pulling reference files itself
# [[ -n "$dada_ref_taxonomy" ]] && args+=(--dada_ref_taxonomy "$dada_ref_taxonomy")
# [[ -n "$dada_ref_tax_custom" ]] && args+=(--dada_ref_tax_custom "$dada_ref_tax_custom")
# [[ -n "$dada_ref_tax_custom_sp" ]] && args+=(--dada_ref_tax_custom_sp "$dada_ref_tax_custom_sp")

[[ -n "$dada_assign_taxlevels" ]] && args+=(--dada_assign_taxlevels "$dada_assign_taxlevels")

[[ -n "$exclude_taxa" ]] && args+=(--exclude_taxa "$exclude_taxa")
[[ -n "$min_frequency" ]] && args+=(--min_frequency "$min_frequency")
[[ -n "$min_samples" ]] && args+=(--min_samples "$min_samples")
[[ -n "$diversity_rarefaction_depth" ]] && args+=(--diversity_rarefaction_depth "$diversity_rarefaction_depth")

# Add optional arguments if set
[[ "$skip_cutadapt" -eq 1 ]] && args+=(--skip_cutadapt)
[[ "$save_intermediates" -eq 1 ]] && args+=(--save_intermediates)
[[ "$multiple_sequencing_runs" -eq 1 ]] && args+=(--multiple_sequencing_runs)
[[ "$ignore_empty_input_files" -eq 1 ]] && args+=(--ignore_empty_input_files)
[[ "$ignore_failed_trimming" -eq 1 ]] && args+=(--ignore_failed_trimming)
[[ "$retain_untrimmed" -eq 1 ]] && args+=(--retain_untrimmed)
[[ "$ignore_failed_filtering" -eq 1 ]] && args+=(--ignore_failed_filtering)
[[ "$vsearch_cluster" -eq 1 ]] && args+=(--vsearch_cluster)
[[ "$dada_taxonomy_rc" -eq 1 ]] && args+=(--dada_taxonomy_rc)
[[ "$picrust" -eq 1 ]] && args+=(--picrust)
[[ "$skip_fastqc" -eq 1 ]] && args+=(--skip_fastqc)
[[ "$skip_dada_quality" -eq 1 ]] && args+=(--skip_dada_quality)
[[ "$skip_barrnap" -eq 1 ]] && args+=(--skip_barrnap)
[[ "$skip_qiime" -eq 1 ]] && args+=(--skip_qiime)
[[ "$skip_qiime_downstream" -eq 1 ]] && args+=(--skip_qiime_downstream)
[[ "$skip_taxonomy" -eq 1 ]] && args+=(--skip_taxonomy)
[[ "$skip_dada_taxonomy" -eq 1 ]] && args+=(--skip_dada_taxonomy)
[[ "$skip_alpha_rarefaction" -eq 1 ]] && args+=(--skip_alpha_rarefaction)
[[ "$skip_diversity_indices" -eq 1 ]] && args+=(--skip_diversity_indices)

[[ -n "$dada_ref_tax_custom_sp" ]] && args+=(--dada_ref_tax_custom_sp "$dada_ref_tax_custom_sp")

# Remove FW_primer and RV_primer from args if skip_cutadapt is set
if [[ "$skip_cutadapt" -eq 1 ]]; then
    args=("${args[@]/--FW_primer*}")
    args=("${args[@]/--RV_primer*}")
fi

echo "args: ${args[@]}"
echo "read_path: $read_path"
ls $read_path

cd ampliseq-16S-pipeline-app-v0.2/

echo "Executing Nextflow run"
./nextflow run nf-core/ampliseq "${args[@]}"

echo "Compressing output folders"
tar -cf nextflow_work_debug.tar ./work ./conf/${conf}.config ./.nextflow/assets/nf-core/ampliseq/nextflow.config ./.nextflow.log
tar -cf ampliseq_16S_pipeline_outputs.tar ./ampliseq_16S_pipeline_outputs

mv nextflow_work_debug.tar ampliseq_16S_pipeline_outputs.tar ../

echo "Cleaning up"
rm -rf ../reads ./dbs ./conf my_list_of_remotely_available_images.txt nextflow 