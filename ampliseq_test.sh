#!/usr/bin/env bash

#SBATCH --job-name=ampliseq_test
#SBATCH --mem=32G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=./ampliseq_test.out
#SBATCH --partition=shared
#SBATCH --time=360

source ~/.bashrc
module load lang/Java/17

export NXF_HOME=$PWD/.nextflow

set -x

# Launch nextflow
echo "Launching Nextflow at $(date)"
./nextflow run nf-core/ampliseq -r 2.14.0 -c conf/hpc.config -profile test,singularity --outdir results