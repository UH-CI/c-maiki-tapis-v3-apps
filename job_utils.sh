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

# Standard cleanup function
cleanup_job() {
    # ONLY FOR DEV. REMOVE IN PROD
    # Add group write permissions
    chmod g+w "$(dirname "$PWD")" 2>/dev/null || true
    chmod -R g+w "$PWD" 2>/dev/null || true
    
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
    echo "Done"
}

# Fail job with optional error message
fail_job() {
    # update_job_status "Failed"
    # _job_status_set=true
    echo "Done"
}

# Export functions
export -f init_tapis_vars
# export -f create_job_info
# export -f create_sequencing_entry
# export -f update_job_status
export -f archive_job_outputs
export -f cleanup_job
export -f setup_tapis_job
export -f complete_job
export -f fail_job