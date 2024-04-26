#!/usr/bin/env bash

source ~/.bashrc
module load lang/Java/11

export NXF_HOME=$PWD/demux-app-v1.0/.nextflow
echo "NXF_HOME: $NXF_HOME"

# Modified to check if variables are set and non-empty before comparison
if [ ! -z "${is_test}" ] && [ "${is_test}" -eq 1 ]; then
    conf="hpc_test"
else
    conf="hpc"
fi
echo "Conf: $conf"

max_mismatches=""
n_per_file=""
n_bases=""
matching=""
reverseComplement=0
singleBarcoded=0 

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

echo "reverseComplement = $reverseComplement"
echo "singleBarcoded = $singleBarcoded"

echo "args: ${args[@]}"

cd demux-app-v1.0/

./nextflow run src/main.nf --inputdir "../reads" ${args[*]} && ./nextflow clean -f -q || echo "Run Failed"

echo "Compressing output folders"
# mv demultiplexed/*.html .
tar -cf nextflow_work_debug.tar ./work ./conf/${conf}.config ./src/nextflow.config ./.nextflow.log ./debug.log
tar -cf demultiplexed_outputs.tar ./demultiplexed
mv demultiplexed_outputs.tar nextflow_work_debug.tar ../

echo "Cleaning up"
cd ../
rm -rf demux-app-v1.0
