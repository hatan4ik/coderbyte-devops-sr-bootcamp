#!/bin/bash
# User Management - List users and their login status

echo "=== System Users ==="
echo "Username | UID | Shell | Last Login"
echo "---------|-----|-------|------------"

while IFS=: read -r username _ uid _ _ _ shell; do
    if [ "$uid" -ge 1000 ] || [ "$username" = "root" ]; then
        last_login=$(last -1 "$username" 2>/dev/null | head -1 | awk '{print $4, $5, $6}' || echo "Never")
        printf "%-8s | %-3s | %-9s | %s\n" "$username" "$uid" "$(basename "$shell")" "$last_login"
    fi
done < /etc/passwd