#!/usr/bin/env bash

source ~/.bashrc
module load lang/Java/11

source ./job_utils.sh

# Job utils function
setup_tapis_job
echo ""

export NXF_HOME=$PWD/demux-app-v1.0/.nextflow

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
    # --outdir ${outdir}
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
echo ""

cd demux-app-v1.0/

echo "Executing Nextflow run" 
# Capture the nextflow exit code immediately
./nextflow run src/main.nf --inputdir "$read_path" ${args[*]}
nextflow_exit_code=$?

if [ $nextflow_exit_code -eq 0 ]; then
    ./nextflow clean -f -q
    echo "Run completed successfully"
else
    echo "Run failed with exit code $nextflow_exit_code"
fi

echo "Compressing output folders"
mv demultiplexed/*.html .
tar -cf nextflow_work_debug.tar ./work ./conf/${conf}.config ./src/nextflow.config ./.nextflow.log
tar -cf demultiplexed_outputs.tar ./demultiplexed
mv demultiplexed_outputs.tar nextflow_work_debug.tar ../

echo "Cleaning up"
cd ../
tar --remove-files -cf tapis_files.tar job_utils.sh tapisjob.env  tapisjob.sh  tapisjob_app.sh
rm -rf ./demux-app-v1.0 ./reads

# Job utils function
if [ $nextflow_exit_code -ne 0 ]; then
    fail_job
else
    complete_job
fi