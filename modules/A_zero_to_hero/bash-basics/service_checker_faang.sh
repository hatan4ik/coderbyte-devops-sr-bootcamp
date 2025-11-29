#!/usr/bin/env bash
# FAANG-Grade Service Checker with Retry and Metrics

set -euo pipefail
IFS=$'\n\t'

readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly LOG_FILE="${LOG_FILE:-/tmp/service_checker.log}"
readonly METRICS_FILE="${METRICS_FILE:-/tmp/service_checker_metrics.prom}"

declare -A SERVICE_STATUS

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

check_service_with_retry() {
    local service="$1"
    local max_retries=3
    local retry_delay=1
    
    for ((attempt=1; attempt<=max_retries; attempt++)); do
        if systemctl is-active --quiet "$service" 2>/dev/null; then
            SERVICE_STATUS["$service"]="running"
            log_info "Service running: $service"
            return 0
        elif pgrep -x "$service" >/dev/null 2>&1; then
            SERVICE_STATUS["$service"]="running"
            log_info "Service running (process): $service"
            return 0
        fi
        
        if [[ $attempt -lt $max_retries ]]; then
            log_info "Retry $attempt for $service in ${retry_delay}s"
            sleep "$retry_delay"
        fi
    done
    
    SERVICE_STATUS["$service"]="stopped"
    log_error "Service not running: $service"
    return 1
}

export_metrics() {
    {
        echo "# HELP service_status Service status (1=running, 0=stopped)"
        echo "# TYPE service_status gauge"
        
        for service in "${!SERVICE_STATUS[@]}"; do
            local status_value=0
            [[ "${SERVICE_STATUS[$service]}" == "running" ]] && status_value=1
            echo "service_status{service=\"$service\"} $status_value"
        done
        
        echo "# HELP service_check_timestamp Last check timestamp"
        echo "# TYPE service_check_timestamp gauge"
        echo "service_check_timestamp $(date +%s)"
    } > "$METRICS_FILE"
}

main() {
    local services=("${@:-ssh cron docker}")
    
    log_info "Checking ${#services[@]} services"
    
    local failed=0
    
    for service in "${services[@]}"; do
        if ! check_service_with_retry "$service"; then
            failed=$((failed + 1))
        fi
    done
    
    export_metrics
    
    # Output JSON
    echo "{"
    echo "  \"total\": ${#services[@]},"
    echo "  \"running\": $((${#services[@]} - failed)),"
    echo "  \"stopped\": $failed,"
    echo "  \"services\": {"
    
    local first=true
    for service in "${!SERVICE_STATUS[@]}"; do
        [[ "$first" == false ]] && echo ","
        echo -n "    \"$service\": \"${SERVICE_STATUS[$service]}\""
        first=false
    done
    
    echo ""
    echo "  }"
    echo "}"
    
    return "$failed"
}

main "$@"
