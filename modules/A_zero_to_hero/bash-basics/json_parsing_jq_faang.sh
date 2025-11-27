#!/usr/bin/env bash
# FAANG-Grade JSON Parser with Validation and Error Handling

set -euo pipefail
IFS=$'\n\t'

readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly LOG_FILE="${LOG_FILE:-/tmp/json_parser.log}"

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp="$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")"
    
    printf '{"timestamp":"%s","level":"%s","script":"%s","message":"%s"}\n' \
        "$timestamp" "$level" "$SCRIPT_NAME" "$message" >> "$LOG_FILE"
}

log_info() { log "INFO" "$@"; }
log_error() { log "ERROR" "$@"; }

validate_json() {
    local json_file="$1"
    
    if ! jq empty "$json_file" 2>/dev/null; then
        log_error "Invalid JSON: $json_file"
        return 1
    fi
    
    log_info "JSON validation passed: $json_file"
    return 0
}

parse_json() {
    local json_file="$1"
    local filter="${2:-.}"
    
    if [[ ! -f "$json_file" ]]; then
        log_error "File not found: $json_file"
        echo "{\"error\":\"File not found: $json_file\"}"
        return 1
    fi
    
    if ! command -v jq &>/dev/null; then
        log_error "jq not installed"
        echo "{\"error\":\"jq is not installed\"}"
        return 1
    fi
    
    if ! validate_json "$json_file"; then
        echo "{\"error\":\"Invalid JSON file\"}"
        return 1
    fi
    
    log_info "Parsing JSON: file=$json_file, filter=$filter"
    
    local result
    if result=$(jq "$filter" "$json_file" 2>&1); then
        log_info "Parse successful"
        echo "$result"
        return 0
    else
        log_error "Parse failed: $result"
        echo "{\"error\":\"Parse failed: $result\"}"
        return 1
    fi
}

main() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: $SCRIPT_NAME <json_file> [jq_filter]" >&2
        echo "Example: $SCRIPT_NAME data.json '.users[] | select(.active==true)'" >&2
        return 1
    fi
    
    local json_file="$1"
    local filter="${2:-.}"
    
    parse_json "$json_file" "$filter"
}

main "$@"
