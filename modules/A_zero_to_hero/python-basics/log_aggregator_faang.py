#!/usr/bin/env python3
"""FAANG-Grade Log Aggregator with Streaming and Result Monad"""

import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterator, Optional

import structlog

log = structlog.get_logger()

@dataclass(frozen=True)
class LogEntry:
    file: str
    line_num: int
    content: str
    timestamp: Optional[str]
    level: Optional[str]

@dataclass(frozen=True)
class AggregateStats:
    total_files: int
    total_entries: int
    error_count: int
    warn_count: int
    info_count: int
    errors_by_file: dict[str, int]

@dataclass(frozen=True)
class Result:
    value: Optional[AggregateStats] = None
    error: Optional[str] = None
    
    @property
    def is_ok(self) -> bool:
        return self.error is None

def extract_log_level(line: str) -> Optional[str]:
    """Extract log level from line"""
    match = re.search(r'\b(ERROR|WARN|INFO|DEBUG)\b', line, re.IGNORECASE)
    return match.group(1).upper() if match else None

def extract_timestamp(line: str) -> Optional[str]:
    """Extract ISO timestamp"""
    match = re.search(r'\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2}', line)
    return match.group() if match else None

def stream_log_entries(file_path: Path) -> Iterator[LogEntry]:
    """Stream log entries with O(1) memory"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            for line_num, line in enumerate(f, 1):
                line = line.strip()
                if line:
                    yield LogEntry(
                        file=str(file_path),
                        line_num=line_num,
                        content=line,
                        timestamp=extract_timestamp(line),
                        level=extract_log_level(line)
                    )
    except Exception as e:
        log.error("file_read_error", file=str(file_path), error=str(e))

def aggregate_logs(pattern: str) -> Result:
    """Aggregate logs from multiple files"""
    try:
        files = list(Path().glob(pattern))
        
        if not files:
            return Result(error=f"No files matching: {pattern}")
        
        total_entries = 0
        error_count = 0
        warn_count = 0
        info_count = 0
        errors_by_file: dict[str, int] = {}
        
        for file_path in files:
            file_errors = 0
            
            for entry in stream_log_entries(file_path):
                total_entries += 1
                
                if entry.level == 'ERROR':
                    error_count += 1
                    file_errors += 1
                elif entry.level == 'WARN':
                    warn_count += 1
                elif entry.level == 'INFO':
                    info_count += 1
            
            if file_errors > 0:
                errors_by_file[str(file_path)] = file_errors
        
        stats = AggregateStats(
            total_files=len(files),
            total_entries=total_entries,
            error_count=error_count,
            warn_count=warn_count,
            info_count=info_count,
            errors_by_file=errors_by_file
        )
        
        log.info("aggregation_complete", **{
            'files': stats.total_files,
            'entries': stats.total_entries,
            'errors': stats.error_count
        })
        
        return Result(value=stats)
    
    except Exception as e:
        log.error("aggregation_failed", error=str(e))
        return Result(error=str(e))

def main(args: list[str]) -> int:
    if len(args) < 2:
        print("Usage: log_aggregator_faang.py <pattern>", file=sys.stderr)
        print("Example: log_aggregator_faang.py '*.log'", file=sys.stderr)
        return 1
    
    result = aggregate_logs(args[1])
    
    if result.is_ok:
        stats = result.value
        output = {
            'total_files': stats.total_files,
            'total_entries': stats.total_entries,
            'error_count': stats.error_count,
            'warn_count': stats.warn_count,
            'info_count': stats.info_count,
            'errors_by_file': stats.errors_by_file
        }
        print(json.dumps(output, indent=2))
        return 0
    else:
        print(json.dumps({'error': result.error}), file=sys.stderr)
        return 1

if __name__ == "__main__":
    structlog.configure(
        processors=[
            structlog.processors.TimeStamper(fmt="iso"),
            structlog.processors.JSONRenderer()
        ]
    )
    sys.exit(main(sys.argv))
