#!/usr/bin/env bash
# FAANG-Grade SSL Certificate Checker with Metrics and Alerting

set -euo pipefail
IFS=$'\n\t'

readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly LOG_FILE="${LOG_FILE:-/tmp/ssl_cert_check.log}"
readonly METRICS_FILE="${METRICS_FILE:-/tmp/ssl_cert_metrics.prom}"
readonly WARN_DAYS=30
readonly CRITICAL_DAYS=7

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

check_ssl_cert() {
    local domain="$1"
    local port="${2:-443}"
    
    log_info "Checking SSL cert: ${domain}:${port}"
    
    local cert_info
    if ! cert_info=$(echo | timeout 10 openssl s_client -servername "$domain" -connect "${domain}:${port}" 2>/dev/null | openssl x509 -noout -dates 2>/dev/null); then
        log_error "Failed to retrieve certificate for $domain"
        return 1
    fi
    
    local expiry
    expiry=$(echo "$cert_info" | grep "notAfter" | cut -d= -f2)
    
    local expiry_epoch
    if [[ "$OSTYPE" == "darwin"* ]]; then
        expiry_epoch=$(date -j -f "%b %d %H:%M:%S %Y %Z" "$expiry" +%s 2>/dev/null || echo 0)
    else
        expiry_epoch=$(date -d "$expiry" +%s 2>/dev/null || echo 0)
    fi
    
    if [[ $expiry_epoch -eq 0 ]]; then
        log_error "Failed to parse expiry date: $expiry"
        return 1
    fi
    
    local current_epoch
    current_epoch=$(date +%s)
    local days_left=$(( (expiry_epoch - current_epoch) / 86400 ))
    
    # Export metrics
    cat >> "$METRICS_FILE" <<EOF
# HELP ssl_cert_expiry_days Days until SSL certificate expires
# TYPE ssl_cert_expiry_days gauge
ssl_cert_expiry_days{domain="$domain",port="$port"} $days_left

# HELP ssl_cert_valid Certificate validity (1=valid, 0=invalid)
# TYPE ssl_cert_valid gauge
ssl_cert_valid{domain="$domain",port="$port"} $([[ $days_left -gt 0 ]] && echo 1 || echo 0)

EOF
    
    # Alert logic
    if [[ $days_left -lt 0 ]]; then
        log_error "Certificate EXPIRED for $domain ($days_left days ago)"
        return 2
    elif [[ $days_left -lt $CRITICAL_DAYS ]]; then
        log_error "Certificate expires in $days_left days (CRITICAL)"
        return 2
    elif [[ $days_left -lt $WARN_DAYS ]]; then
        log_warn "Certificate expires in $days_left days (WARNING)"
        return 1
    else
        log_info "Certificate valid for $days_left days"
        return 0
    fi
}

main() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: $SCRIPT_NAME <domain> [port]" >&2
        echo "Example: $SCRIPT_NAME example.com 443" >&2
        return 1
    fi
    
    local domain="$1"
    local port="${2:-443}"
    
    # Clear metrics file
    > "$METRICS_FILE"
    
    check_ssl_cert "$domain" "$port"
    local exit_code=$?
    
    cat >> "$METRICS_FILE" <<EOF
# HELP ssl_cert_check_timestamp Last check timestamp
# TYPE ssl_cert_check_timestamp gauge
ssl_cert_check_timestamp $(date +%s)
EOF
    
    return "$exit_code"
}

main "$@"
