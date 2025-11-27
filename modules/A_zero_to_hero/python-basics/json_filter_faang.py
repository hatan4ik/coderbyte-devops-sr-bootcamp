#!/usr/bin/env python3
"""FAANG-Grade JSON Filter with Type Safety and Validation"""

import json
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Optional

import structlog

log = structlog.get_logger()

@dataclass(frozen=True)
class FilterResult:
    total: int
    filtered: int
    data: list[dict]

@dataclass(frozen=True)
class Result:
    value: Optional[FilterResult] = None
    error: Optional[str] = None
    
    @property
    def is_ok(self) -> bool:
        return self.error is None

def filter_json_data(file_path: Path, key: Optional[str] = None, value: Optional[str] = None) -> Result:
    """Filter JSON with validation"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        if not isinstance(data, list):
            data = [data]
        
        if key and value:
            filtered = [
                item for item in data 
                if isinstance(item, dict) and str(item.get(key)) == value
            ]
        else:
            filtered = data
        
        log.info("json_filtered", total=len(data), filtered=len(filtered), key=key, value=value)
        
        return Result(value=FilterResult(
            total=len(data),
            filtered=len(filtered),
            data=filtered
        ))
    
    except FileNotFoundError:
        log.error("file_not_found", file=str(file_path))
        return Result(error=f"File not found: {file_path}")
    except json.JSONDecodeError as e:
        log.error("json_decode_error", file=str(file_path), error=str(e))
        return Result(error=f"Invalid JSON: {e}")
    except Exception as e:
        log.error("filter_failed", error=str(e))
        return Result(error=str(e))

def main(args: list[str]) -> int:
    if len(args) < 2:
        print("Usage: json_filter_faang.py <file> [key] [value]", file=sys.stderr)
        return 1
    
    file_path = Path(args[1])
    key = args[2] if len(args) > 2 else None
    value = args[3] if len(args) > 3 else None
    
    result = filter_json_data(file_path, key, value)
    
    if result.is_ok:
        output = {
            'total': result.value.total,
            'filtered': result.value.filtered,
            'data': result.value.data
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
