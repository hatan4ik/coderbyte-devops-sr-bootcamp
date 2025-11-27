#!/usr/bin/env bash
# FAANG-Grade Port Scanner with Concurrent Scanning and JSON Output

set -euo pipefail
IFS=$'\n\t'

readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly LOG_FILE="${LOG_FILE:-/tmp/port_scanner.log}"
readonly TIMEOUT=3
readonly MAX_PARALLEL=10

declare -A PORT_STATUS

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

scan_port() {
    local host="$1"
    local port="$2"
    
    if timeout "$TIMEOUT" bash -c "exec 3<>/dev/tcp/$host/$port 2>/dev/null"; then
        PORT_STATUS["$port"]="open"
        log_info "Port open: ${host}:${port}"
        exec 3>&-
        return 0
    else
        PORT_STATUS["$port"]="closed"
        log_info "Port closed: ${host}:${port}"
        return 1
    fi
}

scan_ports_concurrent() {
    local host="$1"
    shift
    local ports=("$@")
    
    log_info "Scanning ${#ports[@]} ports on $host"
    
    local pids=()
    local count=0
    
    for port in "${ports[@]}"; do
        scan_port "$host" "$port" &
        pids+=($!)
        
        count=$((count + 1))
        
        # Limit concurrent scans
        if [[ $count -ge $MAX_PARALLEL ]]; then
            for pid in "${pids[@]}"; do
                wait "$pid" 2>/dev/null || true
            done
            pids=()
            count=0
        fi
    done
    
    # Wait for remaining
    for pid in "${pids[@]}"; do
        wait "$pid" 2>/dev/null || true
    done
}

output_json() {
    local host="$1"
    
    local open_count=0
    local closed_count=0
    
    for status in "${PORT_STATUS[@]}"; do
        [[ "$status" == "open" ]] && open_count=$((open_count + 1)) || closed_count=$((closed_count + 1))
    done
    
    echo "{"
    echo "  \"host\": \"$host\","
    echo "  \"total_ports\": ${#PORT_STATUS[@]},"
    echo "  \"open\": $open_count,"
    echo "  \"closed\": $closed_count,"
    echo "  \"ports\": {"
    
    local first=true
    for port in "${!PORT_STATUS[@]}"; do
        [[ "$first" == false ]] && echo ","
        echo -n "    \"$port\": \"${PORT_STATUS[$port]}\""
        first=false
    done
    
    echo ""
    echo "  }"
    echo "}"
}

main() {
    if [[ $# -lt 2 ]]; then
        echo "Usage: $SCRIPT_NAME <host> <port1> [port2] ..." >&2
        echo "Example: $SCRIPT_NAME example.com 80 443 8080" >&2
        return 1
    fi
    
    local host="$1"
    shift
    local ports=("$@")
    
    scan_ports_concurrent "$host" "${ports[@]}"
    output_json "$host"
    
    return 0
}

main "$@"
