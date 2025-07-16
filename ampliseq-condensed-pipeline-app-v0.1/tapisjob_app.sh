#!/usr/bin/env bash

source ~/.bashrc
module load lang/Java/11

export NXF_HOME=$PWD/ampliseq-condensed-pipeline-app-v0.1/.nextflow
export NXF_SINGULARITY_CACHEDIR=/home/andyyu/apps/singularity_images.cache
echo "NXF_HOME: $NXF_HOME"

# Check if is_test is set and non-empty before comparison
if [ ! -z "${is_test}" ] && [ "${is_test}" -eq 1 ]; then
    conf="hpc_test"
else
    conf="hpc"
fi
echo "Conf: $conf"

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --input_fasta) input_fasta="$2"; shift ;;
        --FW_primer) FW_primer="$2"; shift ;;
        --RV_primer) RV_primer="$2"; shift ;;
        --save_intermediates) save_intermediates=1 ;;
        --illumina_novaseq) illumina_novaseq=1 ;;
        --pacbio) pacbio=1 ;;
        --iontorrent) iontorrent=1 ;;
        --single_end) single_end=1 ;;
        --illumina_pe_its) illumina_pe_its=1 ;;
        --multiple_sequencing_runs) multiple_sequencing_runs=1 ;;
        --extension) extension="$2"; shift ;;
        --min_read_counts) min_read_counts="$2"; shift ;;
        --ignore_empty_input_files) ignore_empty_input_files=1 ;;
        --ignore_failed_trimming) ignore_failed_trimming=1 ;;
        --trunclenf) trunclenf="$2"; shift ;;
        --trunclenr) trunclenr="$2"; shift ;;
        --max_ee) max_ee="$2"; shift ;;
        --min_len) min_len="$2"; shift ;;
        --ignore_failed_filtering) ignore_failed_filtering=1 ;;
        --dada_ref_taxonomy) dada_ref_taxonomy="$2"; shift ;;
        --dada_taxonomy_rc) dada_taxonomy_rc=1 ;;
        --picrust) picrust=1 ;;
        --exclude_taxa) exclude_taxa="$2"; shift ;;
        --min_frequency) min_frequency="$2"; shift ;;
        --min_samples) min_samples="$2"; shift ;;
        --skip_fastqc) skip_fastqc=1 ;;
        --skip_dada_quality) skip_dada_quality=1 ;;
        --skip_barrnap) skip_barrnap=1 ;;
        --skip_qiime) skip_qiime=1 ;;
        --skip_qiime_downstream) skip_qiime_downstream=1 ;;
        --skip_taxonomy) skip_taxonomy=1 ;;
        --skip_dada_taxonomy) skip_dada_taxonomy=1 ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

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

# Construct arguments array
args=(
    # -r 2.7.1
    -r 2.11.0
    # -profile singularity
    -c "conf/${conf}.config"
    --input "${read_path}"
    # --input_folder "${read_path}"
    # --extension "/*_R{1,2}.fastq.gz"
    --outdir "./ampliseq_condensed_pipeline_outputs"
)

# Conditionally add parameters if they are not empty
[[ -n "$FW_primer" ]] && args+=(--FW_primer "$FW_primer")
[[ -n "$RV_primer" ]] && args+=(--RV_primer "$RV_primer")
[[ -n "$extension" ]] && args+=(--extension "$extension")
[[ -n "$min_read_counts" ]] && args+=(--min_read_counts "$min_read_counts")
[[ -n "$trunclenf" ]] && args+=(--trunclenf "$trunclenf")
[[ -n "$trunclenr" ]] && args+=(--trunclenr "$trunclenr")
[[ -n "$max_ee" ]] && args+=(--max_ee "$max_ee")
[[ -n "$min_len" ]] && args+=(--min_len "$min_len")
[[ -n "$dada_ref_taxonomy" ]] && args+=(--dada_ref_taxonomy "$dada_ref_taxonomy")
[[ -n "$exclude_taxa" ]] && args+=(--exclude_taxa "$exclude_taxa")
[[ -n "$min_frequency" ]] && args+=(--min_frequency "$min_frequency")
[[ -n "$min_samples" ]] && args+=(--min_samples "$min_samples")

# Add optional arguments
[[ "$save_intermediates" -eq 1 ]] && args+=(--save_intermediates)
[[ "$illumina_novaseq" -eq 1 ]] && args+=(--illumina_novaseq)
[[ "$pacbio" -eq 1 ]] && args+=(--pacbio)
[[ "$iontorrent" -eq 1 ]] && args+=(--iontorrent)
[[ "$single_end" -eq 1 ]] && args+=(--single_end)
[[ "$illumina_pe_its" -eq 1 ]] && args+=(--illumina_pe_its)
[[ "$multiple_sequencing_runs" -eq 1 ]] && args+=(--multiple_sequencing_runs)
[[ "$ignore_empty_input_files" -eq 1 ]] && args+=(--ignore_empty_input_files)
[[ "$ignore_failed_trimming" -eq 1 ]] && args+=(--ignore_failed_trimming)
[[ "$ignore_failed_filtering" -eq 1 ]] && args+=(--ignore_failed_filtering)
[[ "$dada_taxonomy_rc" -eq 1 ]] && args+=(--dada_taxonomy_rc)
[[ "$picrust" -eq 1 ]] && args+=(--picrust)
[[ "$skip_fastqc" -eq 1 ]] && args+=(--skip_fastqc)
[[ "$skip_dada_quality" -eq 1 ]] && args+=(--skip_dada_quality)
[[ "$skip_barrnap" -eq 1 ]] && args+=(--skip_barrnap)
[[ "$skip_qiime" -eq 1 ]] && args+=(--skip_qiime)
[[ "$skip_qiime_downstream" -eq 1 ]] && args+=(--skip_qiime_downstream)
[[ "$skip_taxonomy" -eq 1 ]] && args+=(--skip_taxonomy)
[[ "$skip_dada_taxonomy" -eq 1 ]] && args+=(--skip_dada_taxonomy)

echo "args: ${args[@]}"

cd ampliseq-condensed-pipeline-app-v0.1/

echo "Executing Nextflow run"
./nextflow run nf-core/ampliseq "${args[@]}"

# echo "Compressing output folders"
# tar -cf nextflow_work_debug.tar ./work ./conf/${conf}.config ./src/nextflow.config ./.nextflow.log ./debug.log
# tar -cf ampliseq_condensed_pipeline_outputs.tar ./ampliseq_condensed_pipeline_outputs

# mv nextflow_work_debug.tar ampliseq_condensed_pipeline_outputs.tar ../

# echo "Cleaning up"
# cd ../
# rm -rf ./ampliseq-condensed-pipeline-app-v0.1 ./reads ./dbs
