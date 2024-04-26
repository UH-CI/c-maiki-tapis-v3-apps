#!/usr/bin/env bash

echo "Starting script: $(date)"

source ~/.bashrc
module load lang/Java/11

export NXF_HOME=$PWD/ITS-pipeline-app-v2.0/.nextflow
echo "NXF_HOME: $NXF_HOME"

# Modified to check if variables are set and non-empty before comparison
if [ ! -z "${is_test}" ] && [ "${is_test}" -eq 1 ]; then
    conf="hpc_test"
else
    conf="hpc"
fi
echo "Conf: $conf"

locus=""
max_expected_error=""
tax_confidence=""
clustering_thresholds=""
alpha_diversity=""
beta_diversity=""
paired_end=0
skip_lulu=0

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
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
    --locus "${locus}"
    --max_expected_error "${max_expected_error}"
    --tax_confidence "${tax_confidence}"
    --clustering_thresholds "${clustering_thresholds}"
    --alpha_diversity "${alpha_diversity}"
    --beta_diversity "${beta_diversity}"
)

echo "args: ${args[@]}"

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

pattern+=$(ls -1 $read_path/*_R1* 2>/dev/null | head -1 | sed 's/.*_R1//')
echo "Final pattern: $pattern" 

cd ITS-pipeline-app-v2.0/

echo "Files in read_path:"
ls "$read_path"

echo "Executing Nextflow run" 
./nextflow run ./src/main.nf --reads "$read_path/$pattern" ${args[*]}

echo "Compressing output folders"
tar -cf nextflow_work_debug.tar ./work ./conf/${conf}.config ./src/nextflow.config ./.nextflow.log ./debug.log
tar -cf ITS-pipeline_outputs.tar ./ITS-pipeline_outputs

mv nextflow_work_debug.tar ITS-pipeline_outputs.tar ../

echo "Cleaning up"
cd ../
rm -rf ./ITS-pipeline-app-v2.0 
# rm -rf ./ITS-pipeline-app-v2.0/$(basename ${reads})

echo "Script execution completed at $(date)"
