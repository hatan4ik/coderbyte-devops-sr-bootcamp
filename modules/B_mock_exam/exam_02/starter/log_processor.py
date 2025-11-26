#!/usr/bin/env python3
"""Production-grade log processor with error handling and metrics."""
import json
import logging
import re
import sys
from collections import Counter
from datetime import datetime
from pathlib import Path
from typing import Dict, Optional

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

STATUS_PATTERN = re.compile(r'"\s*(\d{3})\s')

def extract_status(line: str) -> Optional[int]:
    """Extract HTTP status code from log line."""
    match = STATUS_PATTERN.search(line)
    if match:
        try:
            return int(match.group(1))
        except ValueError:
            return None
    return None

def process_log(path: str) -> Dict:
    """Process log file and return statistics."""
    counts = Counter()
    total_lines = 0
    error_lines = 0
    start_time = datetime.utcnow()

    try:
        if path == "-":
            lines = sys.stdin
        else:
            file_path = Path(path)
            if not file_path.exists():
                raise FileNotFoundError(f"Log file not found: {path}")
            lines = file_path.open()

        for line in lines:
            total_lines += 1
            status = extract_status(line)
            if status:
                counts[status] += 1
            else:
                error_lines += 1

        if path != "-":
            lines.close()

    except Exception as e:
        logger.error(f"Error processing log: {e}")
        raise

    processing_time = (datetime.utcnow() - start_time).total_seconds()
    logger.info(f"Processed {total_lines} lines in {processing_time:.2f}s")

    return {
        "status_counts": {str(code): count for code, count in sorted(counts.items())},
        "metadata": {
            "total_lines": total_lines,
            "parsed_lines": sum(counts.values()),
            "error_lines": error_lines,
            "processing_time_seconds": round(processing_time, 2),
            "timestamp": datetime.utcnow().isoformat() + "Z"
        }
    }

if __name__ == "__main__":
    target = sys.argv[1] if len(sys.argv) > 1 else "access.log"
    try:
        result = process_log(target)
        print(json.dumps(result, indent=2))
    except Exception as e:
        logger.error(f"Failed to process log: {e}")
        sys.exit(1)
