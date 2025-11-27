#!/usr/bin/env python3
"""FAANG-Grade CSV Parser with Streaming and Type Safety"""

import csv
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterator, Optional

import structlog

log = structlog.get_logger()

@dataclass(frozen=True)
class ColumnStats:
    name: str
    count: int
    mean: float
    min: float
    max: float
    sum: float

@dataclass(frozen=True)
class CSVAnalysis:
    total_rows: int
    columns: list[str]
    numeric_stats: list[ColumnStats]

def stream_csv(file_path: Path) -> Iterator[dict]:
    """Stream CSV rows with O(1) memory"""
    with open(file_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            yield row

def analyze_csv(file_path: Path) -> Optional[CSVAnalysis]:
    """Analyze CSV with streaming to minimize memory"""
    try:
        # First pass: collect column names and numeric data
        numeric_data: dict[str, list[float]] = {}
        columns: list[str] = []
        row_count = 0
        
        for row in stream_csv(file_path):
            if row_count == 0:
                columns = list(row.keys())
                numeric_data = {col: [] for col in columns}
            
            row_count += 1
            
            for col, value in row.items():
                try:
                    numeric_data[col].append(float(value))
                except (ValueError, TypeError):
                    pass
        
        if row_count == 0:
            log.warning("empty_csv", file=str(file_path))
            return None
        
        # Calculate statistics
        stats = []
        for col, values in numeric_data.items():
            if values:
                stats.append(ColumnStats(
                    name=col,
                    count=len(values),
                    mean=sum(values) / len(values),
                    min=min(values),
                    max=max(values),
                    sum=sum(values)
                ))
        
        log.info("csv_analyzed", rows=row_count, columns=len(columns), numeric_cols=len(stats))
        
        return CSVAnalysis(
            total_rows=row_count,
            columns=columns,
            numeric_stats=stats
        )
    
    except FileNotFoundError:
        log.error("file_not_found", file=str(file_path))
        return None
    except Exception as e:
        log.error("csv_parse_error", file=str(file_path), error=str(e))
        return None

def main(args: list[str]) -> int:
    if len(args) < 2:
        print("Usage: csv_parser_faang.py <csv_file>", file=sys.stderr)
        return 1
    
    file_path = Path(args[1])
    
    if not file_path.exists():
        log.error("file_not_found", file=str(file_path))
        return 1
    
    analysis = analyze_csv(file_path)
    
    if not analysis:
        return 1
    
    print(f"Total rows: {analysis.total_rows}")
    print(f"Columns: {', '.join(analysis.columns)}")
    
    if analysis.numeric_stats:
        print("\nNumeric Statistics:")
        for stat in analysis.numeric_stats:
            print(f"  {stat.name}:")
            print(f"    count={stat.count}, mean={stat.mean:.2f}")
            print(f"    min={stat.min}, max={stat.max}, sum={stat.sum:.2f}")
    
    return 0

if __name__ == "__main__":
    structlog.configure(
        processors=[
            structlog.processors.TimeStamper(fmt="iso"),
            structlog.processors.JSONRenderer()
        ]
    )
    sys.exit(main(sys.argv))
