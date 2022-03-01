for f in $(ls *.tar); do
    tar -xf ${f} && rm ${f}
done

# tar -xvzf databases.tar.gz

export NXF_HOME=$PWD/.nextflow

[ ${isTest} -eq 0 ] && conf="local" || conf="local_test"
[ ${pairedEnd} -eq 1 ] && args+=(--pairedEnd) && suffix='*_R{1,2}.fastq*' || suffix='*_R1.fastq*'

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
tar -cf nextflow_work_debug.tar work conf/hpc.config src/nextflow.config
tar -cf ITS-pipeline_outputs.tar ITS-pipeline_outputs

echo "Cleaning up"
# rm -rf conf nextflow .nextflow* scripts src ITS-pipeline_outputs work databases
# rm -rf $(basename ${reads})
rm -rf ITS-pipeline_outputs ITS-pipeline_outputs.tar .nextflow.log* nextflow_work_debug.tar
