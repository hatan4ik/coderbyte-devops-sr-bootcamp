#!/usr/bin/env python3
"""FAANG-Grade Process Monitor with Prometheus Metrics"""

import json
import sys
from dataclasses import dataclass
from typing import Protocol

import psutil
import structlog
from prometheus_client import Gauge, generate_latest

log = structlog.get_logger()

# Metrics
process_cpu_percent = Gauge('process_cpu_percent', 'CPU usage', ['pid', 'name'])
process_memory_percent = Gauge('process_memory_percent', 'Memory usage', ['pid', 'name'])
process_count = Gauge('process_count_total', 'Total processes')

@dataclass(frozen=True)
class ProcessInfo:
    pid: int
    name: str
    cpu_percent: float
    memory_percent: float
    status: str
    num_threads: int

class ProcessMonitor(Protocol):
    def get_processes(self, filter_name: str = None) -> list[ProcessInfo]: ...

@dataclass
class FAANGProcessMonitor:
    top_n: int = 20
    
    def get_processes(self, filter_name: str = None) -> list[ProcessInfo]:
        processes = []
        
        for proc in psutil.process_iter(['pid', 'name', 'cpu_percent', 'memory_percent', 'status', 'num_threads']):
            try:
                info = proc.info
                
                if filter_name and filter_name.lower() not in info['name'].lower():
                    continue
                
                proc_info = ProcessInfo(
                    pid=info['pid'],
                    name=info['name'],
                    cpu_percent=info['cpu_percent'] or 0.0,
                    memory_percent=info['memory_percent'] or 0.0,
                    status=info['status'],
                    num_threads=info['num_threads'] or 0
                )
                
                processes.append(proc_info)
                
                # Update metrics
                process_cpu_percent.labels(
                    pid=str(proc_info.pid),
                    name=proc_info.name[:20]
                ).set(proc_info.cpu_percent)
                
                process_memory_percent.labels(
                    pid=str(proc_info.pid),
                    name=proc_info.name[:20]
                ).set(proc_info.memory_percent)
                
            except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
                continue
        
        process_count.set(len(processes))
        
        # Sort by CPU usage
        processes.sort(key=lambda p: p.cpu_percent, reverse=True)
        
        log.info("processes_monitored", total=len(processes), filter=filter_name)
        
        return processes[:self.top_n]
    
    def get_metrics(self) -> str:
        return generate_latest().decode('utf-8')

def format_text(processes: list[ProcessInfo]) -> str:
    lines = [f"{'PID':<8} {'Name':<20} {'CPU%':<8} {'Mem%':<8} {'Threads':<8} {'Status':<10}"]
    lines.append("-" * 70)
    
    for p in processes:
        lines.append(
            f"{p.pid:<8} {p.name[:19]:<20} {p.cpu_percent:<8.1f} "
            f"{p.memory_percent:<8.1f} {p.num_threads:<8} {p.status:<10}"
        )
    
    return "\n".join(lines)

def format_json(processes: list[ProcessInfo]) -> str:
    data = [
        {
            'pid': p.pid,
            'name': p.name,
            'cpu_percent': p.cpu_percent,
            'memory_percent': p.memory_percent,
            'status': p.status,
            'num_threads': p.num_threads
        }
        for p in processes
    ]
    return json.dumps({'processes': data, 'total': len(data)}, indent=2)

def main(args: list[str]) -> int:
    filter_name = args[1] if len(args) > 1 else None
    output_format = args[2] if len(args) > 2 else 'text'
    
    monitor = FAANGProcessMonitor(top_n=20)
    processes = monitor.get_processes(filter_name)
    
    if not processes:
        log.warning("no_processes_found", filter=filter_name)
        return 1
    
    if output_format == 'json':
        print(format_json(processes))
    elif output_format == 'metrics':
        print(monitor.get_metrics())
    else:
        print(format_text(processes))
    
    return 0

if __name__ == "__main__":
    structlog.configure(
        processors=[
            structlog.processors.TimeStamper(fmt="iso"),
            structlog.processors.JSONRenderer()
        ]
    )
    sys.exit(main(sys.argv))
