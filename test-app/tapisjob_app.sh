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

# Run test script
bash test.sh "$count"
test_exit_code=$?

if [ $test_exit_code -eq 0 ]; then
    echo "Run completed successfully"
else
    echo "Run failed with exit code $test_exit_code"
fi

# Job utils function
if [ $test_exit_code -ne 0 ]; then
    fail_job
else
    complete_job
fi