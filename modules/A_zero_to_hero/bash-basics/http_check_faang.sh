#!/usr/bin/env bash
# FAANG-grade HTTP health checker with retry, timeout, and metrics

set -euo pipefail
IFS=$'\n\t'

# Configuration
readonly SCRIPT_NAME=$(basename "$0")
readonly TIMEOUT=${TIMEOUT:-10}
readonly MAX_RETRIES=${MAX_RETRIES:-3}
readonly RETRY_DELAY=${RETRY_DELAY:-2}
readonly LOG_FILE=${LOG_FILE:-/tmp/http_check.log}

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Metrics
declare -i total_checks=0
declare -i successful_checks=0
declare -i failed_checks=0

# Logging with structured format
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "{\"timestamp\":\"$timestamp\",\"level\":\"$level\",\"message\":\"$message\"}" | tee -a "$LOG_FILE"
}

log_info() { log "INFO" "$@"; }
log_warn() { log "WARN" "$@"; }
log_error() { log "ERROR" "$@"; }

# Error handling
error_exit() {
    log_error "$1"
    exit "${2:-1}"
}

# Trap errors
trap 'error_exit "Script failed at line $LINENO" 1' ERR

# Usage
usage() {
    cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS] <url>

FAANG-grade HTTP health checker with retry, timeout, and metrics.

OPTIONS:
    -t, --timeout SECONDS    Request timeout (default: $TIMEOUT)
    -r, --retries COUNT      Max retry attempts (default: $MAX_RETRIES)
    -d, --delay SECONDS      Delay between retries (default: $RETRY_DELAY)
    -j, --json               Output in JSON format
    -m, --metrics            Output Prometheus metrics
    -h, --help               Show this help message

EXAMPLES:
    $SCRIPT_NAME https://example.com
    $SCRIPT_NAME -t 5 -r 2 https://api.example.com/health
    $SCRIPT_NAME --json https://example.com

ENVIRONMENT:
    TIMEOUT       Override default timeout
    MAX_RETRIES   Override default max retries
    RETRY_DELAY   Override default retry delay
    LOG_FILE      Log file path (default: /tmp/http_check.log)
EOF
    exit 0
}

# Parse arguments
parse_args() {
    local output_format="text"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--timeout)
                TIMEOUT="$2"
                shift 2
                ;;
            -r|--retries)
                MAX_RETRIES="$2"
                shift 2
                ;;
            -d|--delay)
                RETRY_DELAY="$2"
                shift 2
                ;;
            -j|--json)
                output_format="json"
                shift
                ;;
            -m|--metrics)
                output_format="metrics"
                shift
                ;;
            -h|--help)
                usage
                ;;
            -*)
                error_exit "Unknown option: $1" 1
                ;;
            *)
                URL="$1"
                shift
                ;;
        esac
    done
    
    [[ -z "${URL:-}" ]] && error_exit "URL is required" 1
    
    echo "$output_format"
}

# Validate URL
validate_url() {
    local url=$1
    
    if [[ ! "$url" =~ ^https?:// ]]; then
        error_exit "Invalid URL: must start with http:// or https://" 1
    fi
}

# Check HTTP endpoint with retry
check_http() {
    local url=$1
    local attempt=1
    local http_code
    local response_time
    local start_time
    local end_time
    
    while [[ $attempt -le $MAX_RETRIES ]]; do
        log_info "Checking $url (attempt $attempt/$MAX_RETRIES)"
        
        start_time=$(date +%s%N)
        
        # Perform HTTP request
        if http_code=$(curl -s -o /dev/null -w "%{http_code}" \
            --max-time "$TIMEOUT" \
            --connect-timeout "$((TIMEOUT / 2))" \
            --retry 0 \
            -H "User-Agent: HealthChecker/1.0" \
            "$url" 2>/dev/null); then
            
            end_time=$(date +%s%N)
            response_time=$(( (end_time - start_time) / 1000000 ))
            
            ((total_checks++))
            
            if [[ "$http_code" -ge 200 && "$http_code" -lt 300 ]]; then
                ((successful_checks++))
                log_info "Success: $url returned HTTP $http_code in ${response_time}ms"
                echo "$http_code:$response_time:success"
                return 0
            elif [[ "$http_code" -ge 500 ]]; then
                log_warn "Server error: HTTP $http_code (attempt $attempt/$MAX_RETRIES)"
            else
                log_warn "Client error: HTTP $http_code"
                echo "$http_code:$response_time:client_error"
                return 1
            fi
        else
            log_error "Request failed: timeout or connection error"
        fi
        
        if [[ $attempt -lt $MAX_RETRIES ]]; then
            log_info "Retrying in ${RETRY_DELAY}s..."
            sleep "$RETRY_DELAY"
        fi
        
        ((attempt++))
    done
    
    ((failed_checks++))
    ((total_checks++))
    log_error "Failed after $MAX_RETRIES attempts"
    echo "0:0:failed"
    return 1
}

# Output formatters
output_text() {
    local result=$1
    local url=$2
    
    IFS=':' read -r http_code response_time status <<< "$result"
    
    if [[ "$status" == "success" ]]; then
        echo -e "${GREEN}✓${NC} $url is accessible (HTTP $http_code, ${response_time}ms)"
        return 0
    else
        echo -e "${RED}✗${NC} $url is not accessible (HTTP $http_code)"
        return 1
    fi
}

output_json() {
    local result=$1
    local url=$2
    
    IFS=':' read -r http_code response_time status <<< "$result"
    
    cat <<EOF
{
  "url": "$url",
  "status": "$status",
  "http_code": $http_code,
  "response_time_ms": $response_time,
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "checks": {
    "total": $total_checks,
    "successful": $successful_checks,
    "failed": $failed_checks
  }
}
EOF
}

output_metrics() {
    cat <<EOF
# HELP http_check_total Total HTTP checks performed
# TYPE http_check_total counter
http_check_total $total_checks

# HELP http_check_success_total Successful HTTP checks
# TYPE http_check_success_total counter
http_check_success_total $successful_checks

# HELP http_check_failed_total Failed HTTP checks
# TYPE http_check_failed_total counter
http_check_failed_total $failed_checks

# HELP http_check_success_rate Success rate of HTTP checks
# TYPE http_check_success_rate gauge
http_check_success_rate $(awk "BEGIN {print ($successful_checks / $total_checks)}")
EOF
}

# Main
main() {
    local output_format
    output_format=$(parse_args "$@")
    
    validate_url "$URL"
    
    log_info "Starting HTTP health check for $URL"
    
    local result
    if result=$(check_http "$URL"); then
        case "$output_format" in
            json)
                output_json "$result" "$URL"
                ;;
            metrics)
                output_metrics
                ;;
            *)
                output_text "$result" "$URL"
                ;;
        esac
        exit 0
    else
        case "$output_format" in
            json)
                output_json "$result" "$URL"
                ;;
            metrics)
                output_metrics
                ;;
            *)
                output_text "$result" "$URL"
                ;;
        esac
        exit 1
    fi
}

main "$@"
