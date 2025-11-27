#!/usr/bin/env python3
"""FAANG-Grade Word Counter with Streaming and Memory Optimization"""

import json
import re
import sys
from collections import Counter
from dataclasses import dataclass
from pathlib import Path
from typing import Iterator

import structlog

log = structlog.get_logger()

@dataclass(frozen=True)
class WordStats:
    total_words: int
    unique_words: int
    top_words: list[tuple[str, int]]
    avg_word_length: float

def stream_words(file_path: Path) -> Iterator[str]:
    """Stream words with O(1) memory"""
    with open(file_path, 'r', encoding='utf-8') as f:
        for line in f:
            words = re.findall(r'\b\w+\b', line.lower())
            yield from words

def analyze_words(file_path: Path, top_n: int = 10) -> WordStats:
    """Analyze words with streaming"""
    word_counter = Counter()
    total_words = 0
    total_length = 0
    
    for word in stream_words(file_path):
        word_counter[word] += 1
        total_words += 1
        total_length += len(word)
    
    avg_length = total_length / total_words if total_words > 0 else 0.0
    
    log.info("word_analysis_complete", 
             total=total_words, 
             unique=len(word_counter),
             avg_length=round(avg_length, 2))
    
    return WordStats(
        total_words=total_words,
        unique_words=len(word_counter),
        top_words=word_counter.most_common(top_n),
        avg_word_length=avg_length
    )

def main(args: list[str]) -> int:
    if len(args) < 2:
        print("Usage: file_word_count_faang.py <file> [top_n]", file=sys.stderr)
        return 1
    
    file_path = Path(args[1])
    top_n = int(args[2]) if len(args) > 2 else 10
    
    if not file_path.exists():
        log.error("file_not_found", file=str(file_path))
        return 1
    
    try:
        stats = analyze_words(file_path, top_n)
        
        output = {
            'total_words': stats.total_words,
            'unique_words': stats.unique_words,
            'avg_word_length': round(stats.avg_word_length, 2),
            'top_words': [{'word': w, 'count': c} for w, c in stats.top_words]
        }
        
        print(json.dumps(output, indent=2))
        return 0
    
    except Exception as e:
        log.error("analysis_failed", error=str(e))
        return 1

if __name__ == "__main__":
    structlog.configure(
        processors=[
            structlog.processors.TimeStamper(fmt="iso"),
            structlog.processors.JSONRenderer()
        ]
    )
    sys.exit(main(sys.argv))
