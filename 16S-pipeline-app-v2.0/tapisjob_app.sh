#!/usr/bin/env bash

echo "Starting script: $(date)"

source ~/.bashrc
module load lang/Java/11

export NXF_HOME=$PWD/16S-pipeline-app-v2.0/.nextflow
echo "NXF_HOME: $NXF_HOME"

# Modified to check if variables are set and non-empty before comparison
if [ ! -z "${is_test}" ] && [ "${is_test}" -eq 1 ]; then
    conf="hpc_test"
else
    conf="hpc"
fi
echo "Conf: $conf"

# All 16S parameters to be received from command-line
trunc_fwd=""
trunc_rev=""
min_read_len=""
max_expected_error=""
min_overlap=""
max_mismatch=""
min_abundance=""
clustering_thresholds=""
custom_subsampling_level=""
min_subsampling=""
subsampling_quantile=""
alpha_diversity=""
beta_diversity=""
taxa_to_filter=""

# Array for taxa filtering
declare -a taxa_blacklist=()

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --single_end) args+=(--single_end) ;;
        --trunc_fwd) trunc_fwd="$2"; shift; args+=(--trunc_fwd "$trunc_fwd") ;;
        --trunc_rev) trunc_rev="$2"; shift; args+=(--trunc_rev "$trunc_rev") ;;
        --min_read_len) min_read_len="$2"; shift; args+=(--min_read_len "$min_read_len") ;;
        --max_expected_error) max_expected_error="$2"; shift; args+=(--max_expected_error "$max_expected_error") ;;
        --pool) args+=(--pool T) ;;
        --min_overlap) min_overlap="$2"; shift; args+=(--min_overlap "$min_overlap") ;;
        --max_mismatch) max_mismatch="$2"; shift; args+=(--max_mismatch "$max_mismatch") ;;
        --min_abundance) min_abundance="$2"; shift; args+=(--min_abundance "$min_abundance") ;;
        --clustering_thresholds) clustering_thresholds="$2"; shift; args+=(--clustering_thresholds "$clustering_thresholds") ;;
        --skip_subsampling) args+=(--skip_subsampling) ;;
        --custom_subsampling_level) 
            if [[ "$2" && ! "$2" =~ ^-- ]]; then
                custom_subsampling_level="$2"; 
                shift; 
                args+=(--custom_subsampling_level "$custom_subsampling_level"); 
            fi ;;
        --min_subsampling) min_subsampling="$2"; shift; args+=(--min_subsampling "$min_subsampling") ;;
        --subsampling_quantile) subsampling_quantile="$2"; shift; args+=(--subsampling_quantile "$subsampling_quantile") ;;
        --remove_unknown) taxa_blacklist+=('unknown') ;;
        --remove_chloroplasts) taxa_blacklist+=('Chloroplast') ;;
        --remove_mitochondria) taxa_blacklist+=('Mitochondria') ;;
        --skip_unifrac) args+=(--skip_unifrac) ;;
        --alpha_diversity) alpha_diversity="$2"; shift; args+=(--alpha_diversity "$alpha_diversity") ;;
        --beta_diversity) beta_diversity="$2"; shift; args+=(--beta_diversity "$beta_diversity") ;;
        --taxa_to_filter) 
            if [[ "$2" && ! "$2" =~ ^-- ]]; then
                taxa_to_filter="$2"; 
                shift; 
                taxa_blacklist+=($(echo "$taxa_to_filter" | tr ',' ';')); 
            fi ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Format taxa_to_filter to be added to args
if [ ${#taxa_blacklist[@]} -gt 0 ]; then
    IFS=';' eval 'taxa_to_filter_all="${taxa_blacklist[*]}"'
    args+=(--taxa_to_filter "${taxa_to_filter_all}")
fi

echo "args before flags: ${args[@]}"

# Conditional operations based on the presence of specific flags in args
if [[ " ${args[*]} " =~ " --single_end " ]]; then
    suffix="*_R1*.fastq*"
    [[ ! -z "$trunc_fwd" ]] && args+=(--trunc_len "$trunc_fwd")
else
    suffix="*_R{1,2}*.fastq*"
    trunc_params=""
    [[ ! -z "$trunc_fwd" ]] && trunc_params+="$trunc_fwd"
    [[ ! -z "$trunc_rev" ]] && { [[ ! -z "$trunc_params" ]] && trunc_params+=","; trunc_params+="$trunc_rev"; }
    [[ ! -z "$trunc_params" ]] && args+=(--trunc_len "$trunc_params")
fi

# Add profile at the start of args
args=(--profile "${conf}" "${args[@]}")

echo "args passed to nextflow: ${args[@]}"

reads_no_ext=$(basename "${reads}" .tar) # in case the reads are provided as a tar file
if [ "${reads_no_ext}" != "${reads}" ]; then
    read_path="$../reads/${reads_no_ext}/${suffix}"
else
    read_path="$../reads/${suffix}"
fi

cd 16S-pipeline-app-v2.0/

echo "read_path: $read_path"

echo "Starting pipeline"
./nextflow run src/main.nf --reads "$read_path" ${args[*]}

echo "Leaving pipeline"

echo "Compressing output folders"
tar -cf nextflow_work_debug.tar ./work ./conf/${conf}.config ./src/nextflow.config ./.nextflow.log
tar -cf 16S-pipeline_outputs.tar ./16S-pipeline_outputs

mv nextflow_work_debug.tar 16S-pipeline_outputs.tar ../

cd ../

echo "Cleaning up"
rm -rf 16S-pipeline-app-v2.0/
# rm -rf ${reads_no_ext}

echo "Script execution completed at $(date)"
