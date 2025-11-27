#!/usr/bin/env bash
# FAANG-Grade Log Rotation with Compression and Retention Policies

set -euo pipefail
IFS=$'\n\t'

readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly LOG_FILE="${LOG_FILE:-/tmp/log_rotation.log}"
readonly METRICS_FILE="${METRICS_FILE:-/tmp/log_rotation_metrics.prom}"

declare -i FILES_ROTATED=0
declare -i FILES_COMPRESSED=0
declare -i FILES_DELETED=0

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp="$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")"
    
    printf '{"timestamp":"%s","level":"%s","script":"%s","message":"%s"}\n' \
        "$timestamp" "$level" "$SCRIPT_NAME" "$message" | tee -a "$LOG_FILE" >&2
}

log_info() { log "INFO" "$@"; }
log_error() { log "ERROR" "$@"; }

rotate_log() {
    local log_file="$1"
    local max_size_mb="$2"
    local retention_count="${3:-5}"
    
    if [[ ! -f "$log_file" ]]; then
        log_error "Log file not found: $log_file"
        return 1
    fi
    
    local file_size
    if [[ "$OSTYPE" == "darwin"* ]]; then
        file_size=$(stat -f%z "$log_file")
    else
        file_size=$(stat -c%s "$log_file")
    fi
    
    local max_size_bytes=$((max_size_mb * 1024 * 1024))
    local size_mb=$((file_size / 1024 / 1024))
    
    log_info "Checking log: $log_file (${size_mb}MB / ${max_size_mb}MB)"
    
    if [[ $file_size -le $max_size_bytes ]]; then
        log_info "Log size below threshold, no rotation needed"
        return 0
    fi
    
    local timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")
    local rotated_file="${log_file}.${timestamp}"
    
    # Rotate
    if mv "$log_file" "$rotated_file"; then
        touch "$log_file"
        FILES_ROTATED=$((FILES_ROTATED + 1))
        log_info "Rotated: $log_file -> $rotated_file"
        
        # Compress
        if gzip "$rotated_file"; then
            FILES_COMPRESSED=$((FILES_COMPRESSED + 1))
            log_info "Compressed: ${rotated_file}.gz"
        fi
    else
        log_error "Failed to rotate: $log_file"
        return 1
    fi
    
    # Cleanup old files
    local old_files
    old_files=$(ls -t "${log_file}".*.gz 2>/dev/null | tail -n +$((retention_count + 1)) || true)
    
    if [[ -n "$old_files" ]]; then
        while IFS= read -r file; do
            if rm -f "$file"; then
                FILES_DELETED=$((FILES_DELETED + 1))
                log_info "Deleted old log: $file"
            fi
        done <<< "$old_files"
    fi
    
    return 0
}

export_metrics() {
    cat > "$METRICS_FILE" <<EOF
# HELP log_rotation_files_rotated Total files rotated
# TYPE log_rotation_files_rotated counter
log_rotation_files_rotated ${FILES_ROTATED}

# HELP log_rotation_files_compressed Total files compressed
# TYPE log_rotation_files_compressed counter
log_rotation_files_compressed ${FILES_COMPRESSED}

# HELP log_rotation_files_deleted Total files deleted
# TYPE log_rotation_files_deleted counter
log_rotation_files_deleted ${FILES_DELETED}

# HELP log_rotation_last_run Last run timestamp
# TYPE log_rotation_last_run gauge
log_rotation_last_run $(date +%s)
EOF
}

main() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: $SCRIPT_NAME <log_file> [max_size_mb] [retention_count]" >&2
        echo "Example: $SCRIPT_NAME /var/log/app.log 10 5" >&2
        return 1
    fi
    
    local log_file="$1"
    local max_size_mb="${2:-10}"
    local retention_count="${3:-5}"
    
    if ! rotate_log "$log_file" "$max_size_mb" "$retention_count"; then
        export_metrics
        return 1
    fi
    
    export_metrics
    log_info "Rotation complete: rotated=$FILES_ROTATED, compressed=$FILES_COMPRESSED, deleted=$FILES_DELETED"
    
    return 0
}

main "$@"
