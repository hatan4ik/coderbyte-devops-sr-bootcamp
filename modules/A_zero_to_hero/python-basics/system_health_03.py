#!/usr/bin/env python3
"""System Health Monitor - Check CPU, memory, and disk usage"""

import psutil
import sys

def check_system_health():
    # CPU usage
    cpu_percent = psutil.cpu_percent(interval=1)
    
    # Memory usage
    memory = psutil.virtual_memory()
    
    # Disk usage
    disk = psutil.disk_usage('/')
    
    print("=== System Health Report ===")
    print(f"CPU Usage: {cpu_percent}%")
    print(f"Memory Usage: {memory.percent}% ({memory.used // (1024**3)}GB / {memory.total // (1024**3)}GB)")
    print(f"Disk Usage: {disk.percent}% ({disk.used // (1024**3)}GB / {disk.total // (1024**3)}GB)")
    
    # Alerts
    alerts = []
    if cpu_percent > 80:
        alerts.append("High CPU usage")
    if memory.percent > 80:
        alerts.append("High memory usage")
    if disk.percent > 80:
        alerts.append("High disk usage")
    
    if alerts:
        print("\n⚠️  Alerts:")
        for alert in alerts:
            print(f"  - {alert}")
    else:
        print("\n✓ System health is good")

if __name__ == "__main__":
    check_system_health()