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

# Find reads dir and resolve inputs
print_section "Reads"
if ! resolve_reads_dir reads; then
    trap - EXIT
    exit 1
fi
read_dir="${reads_dir}/"
read_path="${reads_dir}/${suffix}"

echo "reads: $read_path"
ls $read_path

# Validate metadata against reads
print_section "Metadata check"
if ! bash ./validate_metadata.sh "$read_dir"; then
    trap - EXIT
    exit 1
fi

# Run test script
print_section "Test run"
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