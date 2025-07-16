#!/usr/bin/env bash

source ~/.bashrc
module load lang/Java/11

export NXF_HOME=$PWD/demux-app-v1.0/.nextflow

# Modified to check if variables are set and non-empty before comparison
if [ ! -z "${is_test}" ] && [ "${is_test}" -eq 1 ]; then
    conf="hpc_test"
else
    conf="hpc"
fi
echo "Conf: $conf"

#Added in curl call for adding in element---------------------------------------------------
id=$(curl -s -X POST "http://128.171.215.53:5000/api/v1/jobinformation" -H "Content-Type: application/json" -d "{\"job_name\": \"Job name temp\", \"job_status\": \"Running\", \"date_submitted\": \"2025-06-23\"}" | jq '.id')
#-------------------------------------------------------------------------------------------

# Cleanup function that runs on script exit
cleanup() {
    # ONLY FOR DEV. REMOVE IN PROD
    # Change file permissions to enable deletion by other users
    chmod -R g+w $PWD 2>/dev/null || true
    
    # Check if script is exiting due to an error and update job status accordingly
    exit_code=$?
    if [ $exit_code -ne 0 ] && [ ! -z "$id" ]; then
        echo "Script failed, updating job status to Failed"
        curl -X PUT "http://128.171.215.53:5000/api/v1/jobinformation/$id" \
             -H "Content-Type: application/json" \
             -d "{\"job_status\": \"Failed\"}" 2>/dev/null || true
    fi
}

# Set trap to run cleanup on script exit (normal or error)
trap cleanup EXIT

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --max_mismatches) max_mismatches="$2"; shift ;;
        --n_per_file) n_per_file="$2"; shift ;;
        --n_bases) n_bases="$2"; shift ;;
        --matching) matching="$2"; shift ;;
        --reverseComplement) reverseComplement=1 ;;
        --singleBarcoded) singleBarcoded=1 ;; 
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

args=(
    -profile ${conf}
    --max_mismatches ${max_mismatches}
    --n_per_file ${n_per_file}
    --n_bases ${n_bases}
    --matching ${matching}
)

[[ "$reverseComplement" -eq 1 ]] && args+=(--reverseComplement)
[[ "$singleBarcoded" -eq 1 ]] && args+=(--singleBarcoded)

echo "args: ${args[@]}"

read_path="${PWD}/reads"
echo "read_path: $read_path"
ls $read_path

cd demux-app-v1.0/

echo "Executing Nextflow run" 
./nextflow run src/main.nf --inputdir "$read_path" ${args[*]} && ./nextflow clean -f -q || echo "Run Failed"

echo "Compressing output folders"
mv demultiplexed/*.html .
tar -cf nextflow_work_debug.tar ./work ./conf/${conf}.config ./src/nextflow.config ./.nextflow.log
tar -cf demultiplexed_outputs.tar ./demultiplexed
mv demultiplexed_outputs.tar nextflow_work_debug.tar ../

echo "Cleaning up"
cd ../
rm -rf ./demux-app-v1.0 ./reads

#Added update curl call-----------------------------------------------------------------
curl -X PUT "http://128.171.215.53:5000/api/v1/jobinformation/$id" -H "Content-Type: application/json" -d "{\"job_status\": \"Completed\"}"
#-------------------------------------------------------------------------------------------
