#!/usr/bin/env bash

for f in $(ls *.tar); do
    tar -xf ${f} && rm ${f}
done

tar -xvzf databases.tar.gz

export NXF_HOME=$PWD/.nextflow

echo "slurm:x:500:500:SLURM Daemon:/var/log/slurm:/sbin/nologin" >>/etc/passwd

[ ${isTest} -eq 0 ] && conf="hpc" || conf="hpc_test"
[ ${pairedEnd} -eq 1 ] && args+=(--pairedEnd) && suffix='*_R{1,2}.fastq*' || suffix='*_R1.fastq*'

clusteringThresholds=${clusteringThresholds//[-]/,}

args=(
    -profile ${conf}
    --locus "${locus}"
    --minQuality ${minQuality}
    --minPercentHighQ ${minPercentWithHighQuality}
    --confidenceThresh ${taxaMinIdentityThreshold}
    --clusteringThresholds "${clusteringThresholds}"
)

reads_no_ext=$(basename ${reads} .tar)

[ ${reads_no_ext} != ${reads} ] && read_path="${PWD}/${reads_no_ext}/reads/${suffix}" || read_path="${PWD}/${reads}/${suffix}"

echo ./nextflow run src/main.nf --reads "$read_path" ${args[*]}
./nextflow run src/main.nf --reads "$read_path" ${args[*]}

echo "Compressing output folders"
tar -cf /output/nextflow_work_debug.tar work conf/hpc.config src/nextflow.config
tar -cf /output/ITS-pipeline_outputs.tar ITS-pipeline_outputs

echo "Cleaning up"
# rm -rf $(basename ${reads})
rm -rf ITS-pipeline_outputs .nextflow.log* databases .nextflow
