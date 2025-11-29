#!/bin/bash
# Port Scanner - Check if ports are open on a host

if [ $# -lt 2 ]; then
    echo "Usage: $0 <host> <port1> [port2] [port3] ..."
    exit 1
fi

host="$1"
shift
ports=("$@")

echo "Scanning ports on $host..."

for port in "${ports[@]}"; do
    if timeout 3 bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null; then
        echo "✓ Port $port: Open"
    else
        echo "✗ Port $port: Closed"
    fi
done