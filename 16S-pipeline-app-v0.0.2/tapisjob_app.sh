#!/usr/bin/env bash

source ~/.bashrc
module load lang/Java/11

cd 16S-pipeline-app-v0.0.2

for f in $(ls *.tar.gz); do
    tar -xzf ${f} && rm ${f}
done

conf="hpc"
rm -f *.tar.gz

export NXF_HOME=$PWD/nf/.nextflow

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --db) db="$2"; shift;;
        --truncFwd) truncFwd="$2"; shift;;
        --truncRev) truncRev="$2"; shift;;
        # --truncLen "${truncationFwd},${truncationRev}"
        --minLength) minReadLength="$2"; shift; args+=(--minLength "${minReadLength}");;
        --maxEE) maxExpectedError="$2"; shift; args+=(--maxEE "${maxExpectedError}");;
        --minOverlap) minOverlapMerging="$2"; shift; args+=(--minOverlap "${minOverlapMerging}");;
        --maxMismatch) maxMismatchMerging="$2"; shift; args+=(--maxMismatch "${maxMismatchMerging}");;
        --subsamplingQuantile) subsamplingQuantile="$2"; shift; args+=(--subsamplingQuantile "${subsamplingQuantile}");;
        --minSubsampling) minSubsampling="$2"; shift; args+=(--minSubsampling "${minSubsampling}");;
        --minAbundance) minAbundanceFilter="$2"; shift; args+=(--minAbundance "${minAbundanceFilter}");;
        --clusteringThresholds) clusteringThresholds="$2"; shift; args+=(--clusteringThresholds "${clusteringThresholds}");;
        --singleEnd) singleEnd=1; args+=(--singleEnd);;
        --customSubsamplingLevel) 
            if [[ "$2" && ! "$2" =~ ^-- ]]; then
                customSubsamplingLevel="$2"; 
                shift; 
                args+=(--customSubsamplingLevel "$customSubsamplingLevel"); 
            fi ;;        
        --skipSubsampling) skipSubsampling=1; args+=(--skipSubsampling);;
        --removeUnknown) removeUnknown=1;;
        --removeMitochondria) removeMitochondria=1;;
        --removeChloroplasts) removeChloroplasts=1;;
        --taxaToFilter) taxaToFilter="$2"; shift;;
        --reads) reads="$2"; shift;;
        --referenceAln) 
            args+=(--referenceAln "${PWD}/${db_aln}"); shift ;;
        --referenceTax) 
            args+=(--referenceTax "${PWD}/${db_tax}"); shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1;;
    esac
    shift
done

if [[ "$db" == "seed" ]]; then
    db_aln=$(ls dbs/silva.seed*/silva.seed*.align)
    db_tax=$(ls dbs/silva.seed*/silva.seed*.tax)
elif [[ "$db" == "nr" ]]; then
    db_aln=$(ls dbs/silva.nr*/silva.nr*.align)
    db_tax=$(ls dbs/silva.nr*/silva.nr*.tax)
fi

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

# reads_no_ext=$(basename ${reads} .tar)
# [ ${reads_no_ext} != ${reads} ] && read_path="${PWD}/${reads_no_ext}/reads/${suffix}" || read_path="${PWD}/${reads}/${suffix}"

# Conditional operations based on the presence of specific flags in args
if [[ " ${args[*]} " =~ " --single_end " ]]; then
    suffix="*_R1*.fastq*"
    [[ ! -z "$truncFwd" ]] && args+=(--truncLen "$truncFwd")
else
    suffix="*_R{1,2}*.fastq*"
    trunc_params=""
    [[ ! -z "$truncFwd" ]] && trunc_params+="$truncFwd"
    [[ ! -z "$truncRev" ]] && { [[ ! -z "$trunc_params" ]] && trunc_params+=","; trunc_params+="$truncRev"; }
    [[ ! -z "$trunc_params" ]] && args+=(--truncLen "$trunc_params")
fi

cd ../

# Build read_path based on single or double end and .tar
reads_no_ext=$(basename "${reads}" .tar) # in case the reads are provided as a tar file
if [ "${reads_no_ext}" != "${reads}" ]; then
    read_dir="${PWD}/${reads_no_ext}/reads/"
    read_path="${PWD}/${reads_no_ext}/reads/${suffix}"
else
    read_dir="${PWD}/reads/"
    read_path="${PWD}/reads/${suffix}"
fi

cd 16S-pipeline-app-v0.0.2 

args=(-profile "${conf}" "${args[@]}")

# Set reference alignment and taxonomy paths
args+=("--referenceAln" "${PWD}/${db_aln}")
args+=("--referenceTax" "${PWD}/${db_tax}")

echo "args: ${args[@]}"]

./nf/nextflow run src/main.nf --reads "$read_path" ${args[*]}
     
# echo "Compressing output folders"
# tar -cf nextflow_work_debug.tar work conf/hpc.config src/nextflow.config
# mkdir filtering_and_denoising_steps
# cd 16S-pipeline_outputs/Misc ; mv 1-* 2-* 3-* ../../filtering_and_denoising_steps ; cd ../..
# tar -cf filtering_and_denoising_steps.tar filtering_and_denoising_steps
# tar -cf 16S-pipeline_outputs.tar 16S-pipeline_outputs

# echo "Cleaning up"
# rm -rf conf nextflow .nextflow scripts src 16S-pipeline_outputs work databases* filtering_and_denoising_steps 
# rm -rf ${reads_no_ext}
