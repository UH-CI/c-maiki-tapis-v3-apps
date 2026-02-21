#!/usr/bin/env bash

source ~/.bashrc

# Source job utils file
source ./job_utils.sh

# Job utils function
setup_tapis_job

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --count) count="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

echo "Count: $count"

# Build read_path based on single or double end and .tar
reads_no_ext=$(basename "${reads}" .tar) # in case the reads are provided as a tar file
if [ "${reads_no_ext}" != "${reads}" ]; then
    read_dir="${PWD}/${reads_no_ext}/reads/"
    read_path="${PWD}/${reads_no_ext}/reads/${suffix}"
else
    read_dir="${PWD}/reads/"
    read_path="${PWD}/reads/${suffix}"
fi

echo "reads: $read_path"
ls $read_path

# Validate metadata against reads
echo "Validating metadata..."
if ! bash ./validate_metadata.sh "$read_dir"; then
    trap - EXIT
    exit 1
fi

# Run test script
bash test-app/test.sh "$count"
test_exit_code=$?

if [ $test_exit_code -eq 0 ]; then
    echo "Run completed successfully"
else
    echo "Run failed with exit code $test_exit_code"
fi

rm -rf test-app reads metadata validate_metadata.sh job_utils.sh tapisjob.env tapisjob.sh tapisjob_app.sh 2>/dev/null || true

# Job utils function
if [ $test_exit_code -ne 0 ]; then
    fail_job
else
    complete_job
fi