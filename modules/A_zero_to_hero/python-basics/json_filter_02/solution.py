#!/usr/bin/env python3
import json
import psutil

def get_system_health() -> dict:
    """
    Gathers system health metrics (CPU, memory, disk) and returns them in a dictionary.
    """
    health_report = {
        "cpu_percent": psutil.cpu_percent(interval=1),
        "memory_percent": psutil.virtual_memory().percent,
        "disk_percent": psutil.disk_usage('/').percent,
    }
    return health_report

if __name__ == "__main__":
    try:
        report = get_system_health()
        print(json.dumps(report, indent=2))
    except Exception as e:
        print(f"Failed to retrieve system health: {e}")
        exit(1)