#!/usr/bin/env bash
# FAANG-Grade Disk Cleanup with JSON Logging and Metrics

set -euo pipefail
IFS=$'\n\t'

readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly LOG_FILE="${LOG_FILE:-/tmp/disk_cleanup.log}"
readonly METRICS_FILE="${METRICS_FILE:-/tmp/disk_cleanup_metrics.prom}"

declare -i FILES_FOUND=0
declare -i FILES_REMOVED=0
declare -i BYTES_FREED=0

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
log_warn() { log "WARN" "$@"; }
log_error() { log "ERROR" "$@"; }

export_metrics() {
    cat > "$METRICS_FILE" <<EOF
# HELP disk_cleanup_files_found Total files found
# TYPE disk_cleanup_files_found counter
disk_cleanup_files_found ${FILES_FOUND}

# HELP disk_cleanup_files_removed Total files removed
# TYPE disk_cleanup_files_removed counter
disk_cleanup_files_removed ${FILES_REMOVED}

# HELP disk_cleanup_bytes_freed Bytes freed
# TYPE disk_cleanup_bytes_freed counter
disk_cleanup_bytes_freed ${BYTES_FREED}

# HELP disk_cleanup_last_run Last run timestamp
# TYPE disk_cleanup_last_run gauge
disk_cleanup_last_run $(date +%s)
EOF
}

cleanup_files() {
    local threshold_mb="$1"
    local action="$2"
    local search_path="${3:-.}"
    
    log_info "Starting cleanup: threshold=${threshold_mb}MB, action=${action}, path=${search_path}"
    
    while IFS= read -r file; do
        if [[ ! -f "$file" ]]; then
            continue
        fi
        
        local size_bytes
        size_bytes=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0)
        local size_mb=$((size_bytes / 1024 / 1024))
        
        FILES_FOUND=$((FILES_FOUND + 1))
        
        log_info "Found file: $file (${size_mb}MB)"
        
        if [[ "$action" == "remove" ]]; then
            if rm -f "$file" 2>/dev/null; then
                FILES_REMOVED=$((FILES_REMOVED + 1))
                BYTES_FREED=$((BYTES_FREED + size_bytes))
                log_info "Removed: $file (${size_mb}MB)"
            else
                log_error "Failed to remove: $file"
            fi
        fi
    done < <(find "$search_path" -type f -size "+${threshold_mb}M" 2>/dev/null)
    
    export_metrics
    
    log_info "Cleanup complete: found=${FILES_FOUND}, removed=${FILES_REMOVED}, freed=$((BYTES_FREED / 1024 / 1024))MB"
}

main() {
    local threshold_mb="${1:-100}"
    local action="${2:-list}"
    local search_path="${3:-.}"
    
    if [[ ! "$threshold_mb" =~ ^[0-9]+$ ]]; then
        log_error "Invalid threshold: $threshold_mb"
        return 1
    fi
    
    if [[ "$action" != "list" && "$action" != "remove" ]]; then
        log_error "Invalid action: $action (must be 'list' or 'remove')"
        return 1
    fi
    
    cleanup_files "$threshold_mb" "$action" "$search_path"
    
    if [[ "$action" == "list" ]]; then
        echo "To remove files, run: $0 $threshold_mb remove $search_path"
    fi
    
    return 0
}

main "$@"
