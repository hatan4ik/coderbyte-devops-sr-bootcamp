#!/usr/bin/env bash
# FAANG-Grade File Organizer with Progress Tracking and Metrics

set -euo pipefail
IFS=$'\n\t'

readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly LOG_FILE="${LOG_FILE:-/tmp/file_organizer.log}"
readonly METRICS_FILE="${METRICS_FILE:-/tmp/file_organizer_metrics.prom}"

declare -i FILES_MOVED=0
declare -i FILES_FAILED=0
declare -i DIRS_CREATED=0

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

organize_files() {
    local target_dir="$1"
    local dry_run="${2:-false}"
    
    if [[ ! -d "$target_dir" ]]; then
        log_error "Directory not found: $target_dir"
        return 1
    fi
    
    log_info "Starting organization: dir=$target_dir, dry_run=$dry_run"
    
    local total_files=0
    while IFS= read -r -d '' file; do
        total_files=$((total_files + 1))
    done < <(find "$target_dir" -maxdepth 1 -type f -print0)
    
    log_info "Found $total_files files to organize"
    
    local current=0
    while IFS= read -r -d '' file; do
        current=$((current + 1))
        local filename
        filename="$(basename "$file")"
        local ext="${filename##*.}"
        
        if [[ "$ext" == "$filename" ]]; then
            ext="no_extension"
        fi
        
        local dest_dir="${target_dir}/${ext}"
        
        if [[ "$dry_run" == "true" ]]; then
            log_info "Would move: $filename -> $ext/"
            continue
        fi
        
        if [[ ! -d "$dest_dir" ]]; then
            if mkdir -p "$dest_dir"; then
                DIRS_CREATED=$((DIRS_CREATED + 1))
                log_info "Created directory: $ext/"
            else
                log_error "Failed to create directory: $ext/"
                FILES_FAILED=$((FILES_FAILED + 1))
                continue
            fi
        fi
        
        if mv "$file" "$dest_dir/"; then
            FILES_MOVED=$((FILES_MOVED + 1))
            log_info "Moved: $filename -> $ext/ (${current}/${total_files})"
        else
            FILES_FAILED=$((FILES_FAILED + 1))
            log_error "Failed to move: $filename"
        fi
    done < <(find "$target_dir" -maxdepth 1 -type f -print0)
    
    return 0
}

export_metrics() {
    cat > "$METRICS_FILE" <<EOF
# HELP file_organizer_files_moved Total files moved
# TYPE file_organizer_files_moved counter
file_organizer_files_moved ${FILES_MOVED}

# HELP file_organizer_files_failed Total files failed
# TYPE file_organizer_files_failed counter
file_organizer_files_failed ${FILES_FAILED}

# HELP file_organizer_dirs_created Total directories created
# TYPE file_organizer_dirs_created counter
file_organizer_dirs_created ${DIRS_CREATED}

# HELP file_organizer_last_run Last run timestamp
# TYPE file_organizer_last_run gauge
file_organizer_last_run $(date +%s)
EOF
}

main() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: $SCRIPT_NAME <directory> [--dry-run]" >&2
        echo "Example: $SCRIPT_NAME /path/to/files" >&2
        return 1
    fi
    
    local target_dir="$1"
    local dry_run="false"
    
    [[ "${2:-}" == "--dry-run" ]] && dry_run="true"
    
    if ! organize_files "$target_dir" "$dry_run"; then
        export_metrics
        return 1
    fi
    
    export_metrics
    
    log_info "Organization complete: moved=$FILES_MOVED, failed=$FILES_FAILED, dirs_created=$DIRS_CREATED"
    
    echo "{\"moved\":$FILES_MOVED,\"failed\":$FILES_FAILED,\"dirs_created\":$DIRS_CREATED}"
    
    return 0
}

main "$@"
