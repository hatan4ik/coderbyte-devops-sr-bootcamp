#!/bin/bash
# Service Checker - Check status of system services

services=("ssh" "cron" "docker" "nginx" "apache2")

echo "=== Service Status Check ==="
for service in "${services[@]}"; do
    if systemctl is-active --quiet "$service" 2>/dev/null; then
        echo "✓ $service: Running"
    elif pgrep "$service" > /dev/null 2>&1; then
        echo "✓ $service: Running (process found)"
    else
        echo "✗ $service: Not running"
    fi
done