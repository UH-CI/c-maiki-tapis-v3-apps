#!/usr/bin/env bash

# Configuration
# API_BASE_URL="http://128.171.215.53:5000/api/v1"

# Global flag to track if job status has been explicitly set
# _job_status_set=false

# Initialize Tapis job variables from environment
init_tapis_vars() {
    job_uuid="$_tapisJobUUID"
    job_name="$_tapisJobName"
    job_owner="$_tapisJobOwner"
    app_id="$_tapisAppId"
    app_version="$_tapisAppVersion"
    archive_system_dir="$_tapisArchiveSystemDir"
    exec_output_dir="$_tapisExecSystemOutputDir"
    
    # Convert Tapis timestamp to YYYY-MM-DD HH:MM:SS UTC format
    job_datetime="${_tapisJobCreateTimestamp/T/ }"
    job_datetime="${job_datetime%.*} UTC"
}

# # Create initial job information entry
# create_job_info() {
#     echo "Creating job info entry in db"
#     curl --silent --output /dev/null --connect-timeout 180 --max-time 180 -X POST "$API_BASE_URL/jobinformation" \
#          -H "Content-Type: application/json" \
#          -d "{\"job_name\": \"$job_name\", \"datetime_submitted\": \"$job_datetime\", \"job_id\": \"$job_uuid\", \"job_owner\": \"$job_owner\", \"app_id\": \"$app_id\", \"app_version\": \"$app_version\"}"
# }

# # Create sequencing entry
# create_sequencing_entry() {
#     echo "Creating sequence entry in db"
#     curl --silent --output /dev/null --connect-timeout 180 --max-time 180 -X POST "$API_BASE_URL/sequencing" \
#          -H "Content-Type: application/json" \
#          -d "{\"sequencing_id\": \"$job_uuid\"}"
# }

# # Update job status
# update_job_status() {
#     local status="$1"
#     local completion_datetime=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
#     echo "Updating job status in db to $status..."
#     curl --silent --output /dev/null --connect-timeout 180 --max-time 180 -X PUT "$API_BASE_URL/jobinformation/$job_uuid" \
#          -H "Content-Type: application/json" \
#          -d "{\"job_status\": \"$status\", \"datetime_completed\": \"$completion_datetime\"}" 2>/dev/null || true
# }

# Archive job outputs if archive system differs from execution system
# archive_job_outputs() {
#     if [ -n "$archive_system_dir" ] && [ -n "$exec_output_dir" ] && [ "$archive_system_dir" != "$exec_output_dir" ]; then
#         echo "Archiving job outputs from $exec_output_dir to $archive_system_dir"
#         cp -r "$exec_output_dir" "$archive_system_dir"
#         # Delete everything except tapisjob.out
#         find . -mindepth 1 ! -name 'tapisjob.out' -exec rm -rf {} + 2>/dev/null || true
#     fi
# }

# Rename job directory by prepending job_name to the directory name
rename_job_dir() {
    if [ -n "$job_name" ]; then
        parent_dir="$(dirname "$PWD")"
        current_dir="$(basename "$PWD")"
        new_dir="${parent_dir}/${job_name}_${current_dir}"
        
        # Only rename if the directory doesn't already have the job_name prefix
        if [[ "$current_dir" != "${job_name}_"* ]]; then
            mv "$PWD" "$new_dir" 2>/dev/null || true
        fi
    fi
}

# Standard cleanup function
cleanup_job() {
    # ONLY FOR DEV. REMOVE IN PROD
    # Add group write permissions
    chmod g+w "$(dirname "$PWD")" 2>/dev/null || true
    chmod -R g+w "$PWD" 2>/dev/null || true

    # rename_job_dir
    
    # Archive outputs if needed
    # archive_job_outputs
    
    # # Check if script is exiting due to an error and update job status accordingly
    # exit_code=$?
    # if [ $exit_code -ne 0 ] && [ "$_job_status_set" = false ]; then
    #     update_job_status "Failed"
    # elif [ "$_job_status_set" = false ]; then
    #     update_job_status "Completed"
    # fi
}

# Setup standard job initialization and cleanup
setup_tapis_job() {
    init_tapis_vars
    trap cleanup_job EXIT
    # create_job_info
    # create_sequencing_entry
}

# Complete job successfully
complete_job() {
    # update_job_status "Completed"
    # _job_status_set=true
    echo "Completed"
}

# Fail job with optional error message
fail_job() {
    # update_job_status "Failed"
    # _job_status_set=true
    echo "Failed"
}

# Find the reads dir and untar tarball if needed
# Sets reads_dir to the absolute path of the folder holding the forward read files.
# With multiple sequencing runs (3rd argument = 1), sets reads_dir to the folder
# holding one subfolder per run, as ampliseq --multiple_sequencing_runs expects.
resolve_reads_dir() {
    local input="${1:-reads}"
    local pattern="${2:-*_R1*.fastq*}"
    local multiple_runs="${3:-0}"
    local tarball r1_file run_dirs run_count parent_dirs parent_count

    # If input is a single file, move it into a folder of the same name
    if [ -f "$input" ]; then
        mv "$input" "${input}.tar"
        mkdir -p "$input"
        mv "${input}.tar" "$input/"
    fi

    # If no reads directly inside, untar tarball
    if ! ls "$input"/$pattern >/dev/null 2>&1; then
        tarball="$input/demultiplexed.tar"
        [ -f "$tarball" ] || tarball=$(find "$input" -maxdepth 1 -type f \( -name "*.tar" -o -name "*.tar.gz" -o -name "*.tgz" \) ! -name "nextflow_work_debug.tar" | head -1)
        if [ -n "$tarball" ]; then
            echo "Unpacking $(basename "$tarball")"
            tar -xf "$tarball" -C "$input" --warning=no-unknown-keyword && rm -f "$tarball"
        fi
    fi

    # Use the folder holding the R1 reads
    r1_file=$(find "$input" -type f -name "$pattern" | head -1)
    if [ -z "$r1_file" ]; then
        echo "ERROR: No read files ($pattern) found in $input"
        return 1
    fi

    if [ "$multiple_runs" -eq 1 ]; then
        # Each folder holding R1 reads is one sequencing run
        run_dirs=$(find "$input" -type f -name "$pattern" -exec dirname {} \; | sort -u)
        run_count=$(( $(printf '%s\n' "$run_dirs" | wc -l) ))
        if [ "$run_count" -lt 2 ]; then
            echo "ERROR: Multiple sequencing runs is on, but all read files are in one folder: $run_dirs"
            echo "Put each run's read files in its own folder, e.g. runA/ and runB/"
            return 1
        fi

        # Run folders must sit side by side in one parent folder, with no reads loose beside them
        parent_dirs=$(while IFS= read -r d; do dirname "$d"; done <<< "$run_dirs" | sort -u)
        parent_count=$(( $(printf '%s\n' "$parent_dirs" | wc -l) ))
        if [ "$parent_count" -ne 1 ]; then
            echo "ERROR: Run folders must sit side by side in one folder, with no read files loose next to them."
            echo "Read files were found in:"
            printf '%s\n' "$run_dirs" | sed 's/^/  /'
            return 1
        fi

        reads_dir=$(cd "$parent_dirs" && pwd)
        echo "Reads folder: $reads_dir"
        echo "Run folders: $(while IFS= read -r d; do basename "$d"; done <<< "$run_dirs" | tr '\n' ' ')"
        return 0
    fi

    reads_dir=$(cd "$(dirname "$r1_file")" && pwd)
    echo "Reads folder: $reads_dir"
}

# Print a blank line and a section header to separate parts of the job log
print_section() {
    echo ""
    echo "==== $1 ===="
}

# Print each flag with its value(s) on its own line
print_args() {
    local arg arg_line=""
    echo "args:"
    for arg in "$@"; do
        if [[ "$arg" == -* && -n "$arg_line" ]]; then
            echo "  ${arg_line}"
            arg_line=""
        fi
        arg_line="${arg_line:+${arg_line} }${arg}"
    done
    [[ -n "$arg_line" ]] && echo "  ${arg_line}"
    return 0
}

# Export functions
export -f init_tapis_vars
# export -f create_job_info
# export -f create_sequencing_entry
# export -f update_job_status
# export -f archive_job_outputs
export -f cleanup_job
export -f setup_tapis_job
export -f complete_job
export -f fail_job
export -f resolve_reads_dir
export -f print_args
export -f print_section