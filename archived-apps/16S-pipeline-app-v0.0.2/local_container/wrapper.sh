#!/usr/bin/env bash
source ~/.bashrc

for f in $(ls *.tar); do
    tar -xf ${f} && rm ${f}
done

[ ${isTest} -eq 0 ] && conf="local" || conf="local_test"
[ ${isTest} -eq 0 ] && tar -xzf databases.tar.gz || tar -xzf databases_test.tar.gz

rm -f *.tar.gz

db_aln=$(ls databases/*.align)
db_tax=$(ls databases/*.tax)

export NXF_HOME=$PWD/.nextflow

args=(
    -profile ${conf}
    --truncLen "${truncationFwd},${truncationRev}"
    --minLength ${minReadLength}
    --maxEE ${maxExpectedError}
    --minOverlap ${minOverlapMerging}
    --maxMismatch ${maxMismatchMerging}
    --subsamplingQuantile ${subsamplingQuantile}
    --minSubsampling ${minSubsampling}
    --minAbundance ${minAbundanceFilter}
    --clusteringThresholds "${clusteringThresholds}"
    --referenceAln "${PWD}/${db_aln}"
    --referenceTax "${PWD}/${db_tax}"
)

[ ${singleEnd} -eq 1 ] && args+=(--singleEnd) && suffix="*_R1*.fastq*" || suffix="*_R{1,2}*.fastq*"
[ ! -z ${customSubsamplingLevel} ] && args+=(--customSubsamplingLevel ${customSubsamplingLevel})
[ ${skipSubsampling} -eq 1 ] && args+=(--skipSubsampling)

taxaBlackList=()
[ ${removeUnknown} -eq 1 ] && taxaBlackList+=('unknown;')
[ ${removeMitochondria} -eq 1 ] && taxaBlackList+=('Bacteria;Proteobacteria;Alphaproteobacteria;Rickettsiales;Mitochondria;')
[ ${removeChloroplasts} -eq 1 ] && taxaBlackList+=('Bacteria;Cyanobacteria;Oxyphotobacteria;Chloroplast;')
[ ! -z ${taxaToFilter} ] && taxaBlackList+=($(echo "${taxaToFilter}" | xargs echo -n | sed 's/,/;/g'))

IFS='-' eval 'taxaToFilterAll="${taxaBlackList[*]}"'
[ ! -z ${taxaToFilterAll} ] && args+=(--taxaToFilter "${taxaToFilterAll}")

reads_no_ext=$(basename ${reads} .tar)
[ ${reads_no_ext} != ${reads} ] && read_path="${PWD}/${reads_no_ext}/reads/${suffix}" || read_path="${PWD}/${reads}/${suffix}"

./nextflow run src/main.nf --reads "$read_path" ${args[*]}
     
echo "Compressing output folders"
tar -cf /output/nextflow_work_debug.tar work conf/hpc.config src/nextflow.config
mkdir filtering_and_denoising_steps
cd 16S-pipeline_outputs/Misc ; mv 1-* 2-* 3-* ../../filtering_and_denoising_steps ; cd ../..
tar -cf /output/filtering_and_denoising_steps.tar filtering_and_denoising_steps
tar -cf /output/16S-pipeline_outputs.tar 16S-pipeline_outputs

echo "Cleaning up"
rm -rf conf nextflow .nextflow scripts src 16S-pipeline_outputs work databases* filtering_and_denoising_steps 
rm -rf ${reads_no_ext}
