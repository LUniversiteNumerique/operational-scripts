#!/bin/bash

# Script to perform rclone sync operations.
# Attempt to sync a folder to a S3 bucket.

load_env_file() {
    if [ ! -f .env ]; then
        echo "Error: .env file not found in current directory."
        exit 1
    fi

    # Load .env
    export $(grep -v '^#' .env | xargs)

    # Check if required variables are set
    if [ -z "$RCLONE_PROFILE_NAME" ] || [ -z "$RCLONE_BUCKET_NAME" ] || [ -z "$RCLONE_SOURCE" ]; then
        echo "Error: RCLONE_PROFILE_NAME, RCLONE_BUCKET_NAME or RCLONE_SOURCE not defined in .env file."
        exit 1
    fi

    echo "Environment variables loaded successfully."
    echo "Source: $RCLONE_SOURCE"
    echo "Destination: $RCLONE_PROFILE_NAME:$RCLONE_BUCKET_NAME"
}

check_rclone() {
    if ! command -v rclone &> /dev/null; then
        echo "Error: rclone is not installed."
        exit 1
    fi

    # Verify rclone is up by checking version
    if ! rclone version &> /dev/null; then
        echo "Error: rclone is installed but not working properly."
        exit 1
    fi
}

check_bucket() {
    local output=$(rclone lsd "$remote_name" 2>&1)

    # Check the exit status of the command
    if [ $? -ne 0 ]; then
        echo "Error running rclone lsd command:"
        echo "$output"
        return 1
    fi

    # Check if there's a line containing the bucket name
    if echo "$output" | grep -q "[[:space:]]$RCLONE_BUCKET_NAME$"; then
        echo "Found $RCLONE_BUCKET_NAME directory in $RCLONE_PROFILE_NAME"
        return 0
    else
        echo "No rclone $RCLONE_PROFILE_NAME bucket found for $RCLONE_BUCKET_NAME."
        return 1
    fi
}

perform_sync() {
    local log_file="/var/log/rclone/rclone_sync_$(date +%Y%m%d_%H%M%S).log"
    local rclone_dest="$RCLONE_PROFILE_NAME:$RCLONE_BUCKET_NAME"

    # Ensure the log directory exists
    log_dir=$(dirname "$log_file")
    if [ ! -d "$log_dir" ]; then
        echo "Log directory does not exist. Attempting to create it."
        if ! mkdir -p "$log_dir"; then
            echo "Error: Failed to create log directory."
            log_file="./rclone_sync_$(date +%Y%m%d_%H%M%S).log"
            echo "Falling back to local directory: $log_file"
        fi
    fi

    # Check if we can write to the log file
    if ! touch "$log_file" 2>/dev/null; then
        echo "Error: Cannot write to $log_file."
        log_file="./rclone_sync_$(date +%Y%m%d_%H%M%S).log"
        echo "Falling back to local directory: $log_file"
        touch "$log_file"
    fi

    echo "Starting rclone sync operation. Log file: $log_file"

    # Perform the sync operation and capture output
    if rclone sync "$RCLONE_SOURCE" "$rclone_dest" --progress 2>&1 | tee "$log_file"; then
        echo "Sync operation completed successfully."
    else
        echo "Error: Sync operation failed. Check the log file for details."
        exit 1
    fi

    grep -E "NOTICE:" "$log_file"
}

main() {
    echo "Rclone Sync Script - $(date)"

    load_env_file
    check_rclone
    check_bucket
    perform_sync

    echo "Rclone operations completed."
}
