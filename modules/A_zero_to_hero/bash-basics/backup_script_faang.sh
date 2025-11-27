#!/usr/bin/env bash
# FAANG-Grade Backup Script with Error Handling, Logging, and Metrics

set -euo pipefail
IFS=$'\n\t'

# Configuration
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="${LOG_FILE:-/tmp/backup_$(date +%Y%m%d).log}"
readonly METRICS_FILE="${METRICS_FILE:-/tmp/backup_metrics.prom}"

# Metrics
declare -i BACKUP_TOTAL=0
declare -i BACKUP_SUCCESS=0
declare -i BACKUP_FAILURE=0
declare -i BACKUP_DURATION_MS=0

# Structured logging
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

# Error handling
trap 'handle_error $? $LINENO' ERR
trap 'cleanup' EXIT INT TERM

handle_error() {
    local exit_code=$1
    local line_number=$2
    log_error "Script failed at line $line_number with exit code $exit_code"
    BACKUP_FAILURE=$((BACKUP_FAILURE + 1))
    export_metrics
    exit "$exit_code"
}

cleanup() {
    log_info "Cleanup completed"
}

# Validation
validate_directory() {
    local dir="$1"
    
    if [[ ! -d "$dir" ]]; then
        log_error "Directory not found: $dir"
        return 1
    fi
    
    if [[ ! -r "$dir" ]]; then
        log_error "Directory not readable: $dir"
        return 1
    fi
    
    return 0
}

# Backup function with retry
backup_with_retry() {
    local source_dir="$1"
    local backup_location="$2"
    local max_retries=3
    local retry_delay=2
    
    for ((attempt=1; attempt<=max_retries; attempt++)); do
        if perform_backup "$source_dir" "$backup_location"; then
            return 0
        fi
        
        if [[ $attempt -lt $max_retries ]]; then
            log_warn "Backup attempt $attempt failed, retrying in ${retry_delay}s..."
            sleep "$retry_delay"
            retry_delay=$((retry_delay * 2))
        fi
    done
    
    return 1
}

perform_backup() {
    local source_dir="$1"
    local backup_location="$2"
    local timestamp
    timestamp="$(date +"%Y%m%d_%H%M%S")"
    local backup_name="backup_$(basename "$source_dir")_${timestamp}.tar.gz"
    local backup_path="${backup_location}/${backup_name}"
    
    local start_time
    start_time="$(date +%s%3N)"
    
    log_info "Starting backup: $source_dir -> $backup_path"
    
    mkdir -p "$backup_location"
    
    if tar -czf "$backup_path" -C "$(dirname "$source_dir")" "$(basename "$source_dir")" 2>/dev/null; then
        local end_time
        end_time="$(date +%s%3N)"
        BACKUP_DURATION_MS=$((end_time - start_time))
        
        local size
        size="$(du -h "$backup_path" | cut -f1)"
        
        log_info "Backup completed: $backup_path (size: $size, duration: ${BACKUP_DURATION_MS}ms)"
        
        # Verify backup
        if tar -tzf "$backup_path" >/dev/null 2>&1; then
            log_info "Backup verification successful"
            BACKUP_SUCCESS=$((BACKUP_SUCCESS + 1))
            return 0
        else
            log_error "Backup verification failed"
            rm -f "$backup_path"
            return 1
        fi
    else
        log_error "Backup creation failed"
        return 1
    fi
}

# Prometheus metrics export
export_metrics() {
    cat > "$METRICS_FILE" <<EOF
# HELP backup_total Total number of backup attempts
# TYPE backup_total counter
backup_total ${BACKUP_TOTAL}

# HELP backup_success Number of successful backups
# TYPE backup_success counter
backup_success ${BACKUP_SUCCESS}

# HELP backup_failure Number of failed backups
# TYPE backup_failure counter
backup_failure ${BACKUP_FAILURE}

# HELP backup_duration_milliseconds Backup duration in milliseconds
# TYPE backup_duration_milliseconds gauge
backup_duration_milliseconds ${BACKUP_DURATION_MS}

# HELP backup_last_run_timestamp Last backup run timestamp
# TYPE backup_last_run_timestamp gauge
backup_last_run_timestamp $(date +%s)
EOF
    
    log_info "Metrics exported to $METRICS_FILE"
}

# Main
main() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: $SCRIPT_NAME <source_directory> [backup_location]" >&2
        echo "Example: $SCRIPT_NAME /var/www /backups" >&2
        return 1
    fi
    
    local source_dir="$1"
    local backup_location="${2:-./backups}"
    
    BACKUP_TOTAL=$((BACKUP_TOTAL + 1))
    
    log_info "Backup script started"
    log_info "Source: $source_dir, Destination: $backup_location"
    
    if ! validate_directory "$source_dir"; then
        BACKUP_FAILURE=$((BACKUP_FAILURE + 1))
        export_metrics
        return 1
    fi
    
    if backup_with_retry "$source_dir" "$backup_location"; then
        export_metrics
        log_info "Backup completed successfully"
        return 0
    else
        BACKUP_FAILURE=$((BACKUP_FAILURE + 1))
        export_metrics
        log_error "Backup failed after all retries"
        return 1
    fi
}

main "$@"
