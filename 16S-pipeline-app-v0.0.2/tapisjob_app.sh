#!/usr/bin/env bash

source ~/.bashrc
module load lang/Java/11

# Source job utils file
source ./job_utils.sh

# Job utils function
setup_tapis_job

cleanup() {
    cd 16S-pipeline-app-v0.0.2 2>/dev/null
    
    echo "Compressing output folders"
    tar -cf ../nextflow_work_debug.tar work conf/hpc.config conf/container.config src/nextflow.config .nextflow .nextflow.log -C .. tapisjob.env 2>/dev/null || true

    mkdir -p filtering_and_denoising_steps 2>/dev/null || true
    cd 16S-pipeline_outputs/Misc 2>/dev/null && mv 1-* 2-* 3-* ../../filtering_and_denoising_steps 2>/dev/null || true
    cd ../.. 2>/dev/null || cd .
    tar -cf ../filtering_and_denoising_steps.tar filtering_and_denoising_steps 2>/dev/null || true
    tar --exclude=16S-pipeline_outputs/Misc -cf ../16S-pipeline_outputs.tar 16S-pipeline_outputs 2>/dev/null || true
    tar -cf ../16S-pipeline_midpoints.tar 16S-pipeline_outputs/Misc 2>/dev/null || true

    echo "Cleaning up"
    rm -rf conf nf scripts 16S-pipeline_outputs work dbs* filtering_and_denoising_steps ../reads src .nextflow .nextflow.log 2>/dev/null || true
    rm -rf ${reads_no_ext} 2>/dev/null || true
    cd ../
    rm -rf metadata validate_metadata.sh 16S-pipeline-app-v0.0.2 tapis_files.tar job_utils.sh tapisjob.env tapisjob.sh tapisjob_app.sh 2>/dev/null || true
    
    # Job utils function
    if [ ${nextflow_exit_code:-1} -ne 0 ]; then
        fail_job
    else
        complete_job
    fi
}

trap cleanup EXIT

cd 16S-pipeline-app-v0.0.2

for f in $(ls *.tar.gz); do
    tar -xzf ${f} --warning=no-unknown-keyword && rm ${f}
done

conf="hpc"
rm -f *.tar.gz

export NXF_HOME=$PWD/nf/.nextflow

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        # --outdir) outdir="$2"; shift; args+=(--outdir "${outdir}");;
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

[ ${singleEnd:-0} -eq 1 ] && args+=(--singleEnd) && suffix="*_R1*.fastq*" || suffix="*_R{1,2}*.fastq*"
[ ! -z ${customSubsamplingLevel} ] && args+=(--customSubsamplingLevel ${customSubsamplingLevel})
[ ${skipSubsampling:-0} -eq 1 ] && args+=(--skipSubsampling)

taxaBlackList=()
[ ${removeUnknown} -eq 1 ] && taxaBlackList+=('unknown;')
[ ${removeMitochondria} -eq 1 ] && taxaBlackList+=('Bacteria;Proteobacteria;Alphaproteobacteria;Rickettsiales;Mitochondria;')
[ ${removeChloroplasts} -eq 1 ] && taxaBlackList+=('Bacteria;Cyanobacteria;Cyanobacteriia;Chloroplast;')
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

# Validate metadata against reads
echo "Validating metadata..."
if ! bash ./validate_metadata.sh "$read_dir"; then
    trap - EXIT
    exit 1
fi

cd 16S-pipeline-app-v0.0.2 

args=(-profile "${conf}" "${args[@]}")

# Set reference alignment and taxonomy paths
args+=("--referenceAln" "${PWD}/${db_aln}")
args+=("--referenceTax" "${PWD}/${db_tax}")

echo "args: ${args[@]}"
echo "reads: $read_path"
ls $read_dir

echo "Executing Nextflow run" 
./nf/nextflow run src/main.nf --reads "$read_path" ${args[*]}
nextflow_exit_code=$?

if [ $nextflow_exit_code -eq 0 ]; then
    ./nf/nextflow clean -f -q
    echo "Run completed successfully"
else
    echo "Run failed with exit code $nextflow_exit_code"
fi