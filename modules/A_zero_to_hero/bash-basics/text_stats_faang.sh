#!/usr/bin/env bash
# FAANG-Grade Text Statistics with Streaming and JSON Output

set -euo pipefail
IFS=$'\n\t'

readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly LOG_FILE="${LOG_FILE:-/tmp/text_stats.log}"

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

analyze_text() {
    local file="$1"
    local output_format="${2:-text}"
    
    if [[ ! -f "$file" ]]; then
        log_error "File not found: $file"
        return 1
    fi
    
    log_info "Analyzing: $file"
    
    local lines words chars bytes
    
    # Streaming analysis
    lines=$(wc -l < "$file" | tr -d ' ')
    words=$(wc -w < "$file" | tr -d ' ')
    chars=$(wc -m < "$file" 2>/dev/null || wc -c < "$file" | tr -d ' ')
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        bytes=$(stat -f%z "$file")
    else
        bytes=$(stat -c%s "$file")
    fi
    
    local avg_line_length=0
    [[ $lines -gt 0 ]] && avg_line_length=$((chars / lines))
    
    local avg_word_length=0
    [[ $words -gt 0 ]] && avg_word_length=$((chars / words))
    
    log_info "Analysis complete: lines=$lines, words=$words, chars=$chars"
    
    if [[ "$output_format" == "json" ]]; then
        cat <<EOF
{
  "file": "$file",
  "lines": $lines,
  "words": $words,
  "characters": $chars,
  "bytes": $bytes,
  "avg_line_length": $avg_line_length,
  "avg_word_length": $avg_word_length
}
EOF
    else
        cat <<EOF
File: $file
Lines: $lines
Words: $words
Characters: $chars
Bytes: $bytes
Avg Line Length: $avg_line_length
Avg Word Length: $avg_word_length
EOF
    fi
    
    return 0
}

main() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: $SCRIPT_NAME <file> [format]" >&2
        echo "Formats: text (default), json" >&2
        echo "Example: $SCRIPT_NAME document.txt json" >&2
        return 1
    fi
    
    local file="$1"
    local format="${2:-text}"
    
    if [[ "$format" != "text" && "$format" != "json" ]]; then
        log_error "Invalid format: $format"
        return 1
    fi
    
    analyze_text "$file" "$format"
}

main "$@"
