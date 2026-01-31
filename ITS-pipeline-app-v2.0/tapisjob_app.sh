#!/usr/bin/env bash

source ~/.bashrc
module load lang/Java/11

# Source job utils file
source ./job_utils.sh

# Job utils function
setup_tapis_job

export NXF_HOME=$PWD/ITS-pipeline-app-v2.0/.nextflow

cleanup() {
    cd ITS-pipeline-app-v2.0/ 2>/dev/null || cd .
    
    echo "Compressing output folders"
    tar -cf ../nextflow_work_debug.tar work ./conf/${conf}.config ./src/nextflow.config .nextflow.log -C .. tapisjob.env 2>/dev/null || true
    tar -cf ../ITS-pipeline_outputs.tar ITS-pipeline_outputs 2>/dev/null || true
    
    mv ../nextflow_work_debug.tar ../ITS-pipeline_outputs.tar ../ 2>/dev/null || true
    
    echo "Cleaning up"
    cd ../
    rm -rf reads metadata validate_metadata.sh ./ITS-pipeline-app-v2.0/dbs ./ITS-pipeline-app-v2.0/conf ./ITS-pipeline-app-v2.0/nextflow 2>/dev/null || true
    rm -rf ITS-pipeline-app-v2.0 job_utils.sh tapisjob.sh tapisjob_app.sh tapisjob.env 2>/dev/null || true
    
    # Job utils function
    if [ ${nextflow_exit_code:-1} -ne 0 ]; then
        fail_job
    else
        complete_job
    fi
}

trap cleanup EXIT

# Modified to check if variables are set and non-empty before comparison
if [ ! -z "${is_test}" ] && [ "${is_test}" -eq 1 ]; then
    conf="hpc_test"
else
    conf="hpc"
fi
echo "Conf: $conf"

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        # --outdir) outdir="$2"; shift ;;
        --locus) locus="$2"; shift ;;
        --paired_end) paired_end=1;;
        --max_expected_error) max_expected_error="$2"; shift ;;
        --tax_confidence) tax_confidence="$2"; shift ;;
        --clustering_thresholds) clustering_thresholds="$2"; shift ;;
        --skip_lulu) skip_lulu=1;;
        --alpha_diversity) alpha_diversity="$2"; shift ;;
        --beta_diversity) beta_diversity="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

args=(
    -profile "${conf}"
    # --outdir "${outdir}"
    --locus "${locus}"
    --max_expected_error "${max_expected_error}"
    --tax_confidence "${tax_confidence}"
    --clustering_thresholds "${clustering_thresholds}"
    --alpha_diversity "${alpha_diversity}"
    --beta_diversity "${beta_diversity}"
)

[[ "$skip_lulu" -eq 1 ]] && args+=(--skip_lulu)

# Check paired-end naming pattern
if [[ "${paired_end}" -eq 1 ]]; then
    args+=(--paired_end)
    pattern="*_R{1,2}"
else 
    pattern="*_R1"
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

# Validate metadata against reads
echo "Validating metadata..."
if ! bash ./validate_metadata.sh "$read_path"; then
    echo "ERROR: Number of samples in metadata does not match number of FASTQ files in reads directory"
    echo "Check that each metadata row has corresponding FASTQ files (paired-end: _R1/_R2, single-end: _R1)"
    trap - EXIT
    exit 1
fi

echo "args: ${args[@]}"
echo "reads: $read_path"
ls $read_path

pattern+=$(ls -1 $read_path/*_R1* 2>/dev/null | head -1 | sed 's/.*_R1//')
cd ITS-pipeline-app-v2.0/

echo "Executing Nextflow run" 
./nextflow run ./src/main.nf --reads "$read_path/$pattern" ${args[*]}
nextflow_exit_code=$?

if [ $nextflow_exit_code -eq 0 ]; then
    ./nextflow clean -f -q
    echo "Run completed successfully"
else
    echo "Run failed with exit code $nextflow_exit_code"
fi