#!/bin/bash
# SSL Certificate Check - Check SSL certificate expiration

if [ $# -eq 0 ]; then
    echo "Usage: $0 <domain> [port]"
    exit 1
fi

domain="$1"
port="${2:-443}"

echo "Checking SSL certificate for $domain:$port"

cert_info=$(echo | openssl s_client -servername "$domain" -connect "$domain:$port" 2>/dev/null | openssl x509 -noout -dates 2>/dev/null)

if [ $? -eq 0 ]; then
    echo "$cert_info"
    expiry=$(echo "$cert_info" | grep "notAfter" | cut -d= -f2)
    expiry_epoch=$(date -d "$expiry" +%s 2>/dev/null || date -j -f "%b %d %H:%M:%S %Y %Z" "$expiry" +%s 2>/dev/null)
    current_epoch=$(date +%s)
    days_left=$(( (expiry_epoch - current_epoch) / 86400 ))
    
    if [ $days_left -lt 30 ]; then
        echo "⚠️  Certificate expires in $days_left days"
    else
        echo "✓ Certificate is valid for $days_left more days"
    fi
else
    echo "✗ Failed to retrieve certificate"
fi