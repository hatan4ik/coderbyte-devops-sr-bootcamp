#!/usr/bin/env python3
"""Process Monitor - Monitor running processes"""

import psutil
import sys
import time

def monitor_processes(process_name=None):
    print("=== Process Monitor ===")
    
    processes = []
    for proc in psutil.process_iter(['pid', 'name', 'cpu_percent', 'memory_percent']):
        try:
            if process_name is None or process_name.lower() in proc.info['name'].lower():
                processes.append(proc.info)
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            pass
    
    if not processes:
        print(f"No processes found matching '{process_name}'")
        return
    
    # Sort by CPU usage
    processes.sort(key=lambda x: x['cpu_percent'] or 0, reverse=True)
    
    print(f"{'PID':<8} {'Name':<20} {'CPU%':<8} {'Memory%':<8}")
    print("-" * 50)
    
    for proc in processes[:20]:  # Top 20
        print(f"{proc['pid']:<8} {proc['name'][:19]:<20} {proc['cpu_percent'] or 0:<8.1f} {proc['memory_percent'] or 0:<8.1f}")

if __name__ == "__main__":
    process_name = sys.argv[1] if len(sys.argv) > 1 else None
    monitor_processes(process_name)