#!/usr/bin/env python3
"""FAANG-grade log parser with streaming, type safety, and observability."""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Iterator, Protocol, Optional, Dict, List
from enum import Enum
from pathlib import Path
from collections import Counter
import re
import structlog
from functools import lru_cache

logger = structlog.get_logger()

class LogLevel(Enum):
    """Log severity levels."""
    ERROR = "ERROR"
    WARN = "WARN"
    INFO = "INFO"
    DEBUG = "DEBUG"

@dataclass(frozen=True)
class LogEntry:
    """Immutable log entry."""
    line_number: int
    raw_line: str
    level: Optional[LogLevel] = None
    timestamp: Optional[str] = None
    message: str = ""
    
    @staticmethod
    def parse(line_number: int, raw_line: str) -> LogEntry:
        """Parse raw log line into structured entry."""
        level = LogEntry._extract_level(raw_line)
        timestamp = LogEntry._extract_timestamp(raw_line)
        message = raw_line.strip()
        
        return LogEntry(
            line_number=line_number,
            raw_line=raw_line,
            level=level,
            timestamp=timestamp,
            message=message
        )
    
    @staticmethod
    @lru_cache(maxsize=128)
    def _extract_level(line: str) -> Optional[LogLevel]:
        """Extract log level with caching."""
        for level in LogLevel:
            if re.search(rf'\b{level.value}\b', line, re.IGNORECASE):
                return level
        return None
    
    @staticmethod
    def _extract_timestamp(line: str) -> Optional[str]:
        """Extract ISO timestamp if present."""
        match = re.search(r'\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}:\d{2}', line)
        return match.group(0) if match else None

@dataclass
class LogStats:
    """Aggregated log statistics."""
    total_lines: int = 0
    by_level: Dict[LogLevel, int] = field(default_factory=lambda: Counter())
    errors: List[LogEntry] = field(default_factory=list)
    warnings: List[LogEntry] = field(default_factory=list)
    
    def add_entry(self, entry: LogEntry):
        """Add entry to statistics."""
        self.total_lines += 1
        
        if entry.level:
            self.by_level[entry.level] += 1
            
            if entry.level == LogLevel.ERROR:
                self.errors.append(entry)
            elif entry.level == LogLevel.WARN:
                self.warnings.append(entry)
    
    def to_dict(self) -> Dict:
        """Convert to dictionary for JSON serialization."""
        return {
            'total_lines': self.total_lines,
            'by_level': {level.value: count for level, count in self.by_level.items()},
            'error_count': len(self.errors),
            'warning_count': len(self.warnings)
        }

class LogParser:
    """FAANG-grade log parser with streaming and memory efficiency."""
    
    def __init__(self, buffer_size: int = 8192):
        self.buffer_size = buffer_size
        self.logger = logger.bind(component="LogParser")
    
    def parse_file(self, filepath: Path) -> LogStats:
        """Parse log file with streaming to handle large files."""
        if not filepath.exists():
            raise FileNotFoundError(f"Log file not found: {filepath}")
        
        self.logger.info("parsing_started", file=str(filepath))
        
        stats = LogStats()
        
        try:
            for entry in self._stream_entries(filepath):
                stats.add_entry(entry)
        except Exception as e:
            self.logger.error("parsing_failed", error=str(e))
            raise
        
        self.logger.info("parsing_completed", 
                        total_lines=stats.total_lines,
                        errors=len(stats.errors),
                        warnings=len(stats.warnings))
        
        return stats
    
    def _stream_entries(self, filepath: Path) -> Iterator[LogEntry]:
        """Stream log entries without loading entire file into memory."""
        with filepath.open('r', buffering=self.buffer_size) as f:
            for line_number, line in enumerate(f, start=1):
                if line.strip():  # Skip empty lines
                    yield LogEntry.parse(line_number, line)

class LogReporter:
    """Generate human-readable reports from log statistics."""
    
    @staticmethod
    def generate_report(stats: LogStats, max_recent: int = 5) -> str:
        """Generate formatted report."""
        lines = [
            "=== Log Analysis Report ===",
            f"Total lines: {stats.total_lines}",
            ""
        ]
        
        # Level breakdown
        if stats.by_level:
            lines.append("By Level:")
            for level, count in sorted(stats.by_level.items(), key=lambda x: x[1], reverse=True):
                lines.append(f"  {level.value}: {count}")
            lines.append("")
        
        # Recent errors
        if stats.errors:
            lines.append(f"Recent Errors (last {max_recent}):")
            for entry in stats.errors[-max_recent:]:
                lines.append(f"  Line {entry.line_number}: {entry.message[:80]}")
            lines.append("")
        
        # Recent warnings
        if stats.warnings:
            lines.append(f"Recent Warnings (last {max_recent}):")
            for entry in stats.warnings[-max_recent:]:
                lines.append(f"  Line {entry.line_number}: {entry.message[:80]}")
        
        return "\n".join(lines)

def main():
    """CLI entry point."""
    import sys
    import json
    
    if len(sys.argv) < 2:
        print("Usage: python log_parser_faang.py <log_file> [--json]")
        sys.exit(1)
    
    filepath = Path(sys.argv[1])
    output_json = "--json" in sys.argv
    
    try:
        parser = LogParser()
        stats = parser.parse_file(filepath)
        
        if output_json:
            print(json.dumps(stats.to_dict(), indent=2))
        else:
            report = LogReporter.generate_report(stats)
            print(report)
        
    except FileNotFoundError as e:
        logger.error("file_not_found", error=str(e))
        sys.exit(1)
    except Exception as e:
        logger.exception("unexpected_error")
        sys.exit(1)

if __name__ == "__main__":
    main()
