#!/usr/bin/env python3
"""File Word Count - Count words and find most frequent words"""

import sys
from collections import Counter
import re

def count_words(filename):
    if not filename:
        print("Usage: python file_word_count_04.py <text_file>")
        return
    
    try:
        with open(filename, 'r') as f:
            content = f.read().lower()
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found")
        return
    
    # Extract words (alphanumeric only)
    words = re.findall(r'\b\w+\b', content)
    word_count = Counter(words)
    
    print(f"Total words: {len(words)}")
    print(f"Unique words: {len(word_count)}")
    
    print("\nTop 10 most frequent words:")
    for word, count in word_count.most_common(10):
        print(f"  {word}: {count}")

if __name__ == "__main__":
    count_words(sys.argv[1] if len(sys.argv) > 1 else None)