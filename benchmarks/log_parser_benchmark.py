#!/usr/bin/env python3
import timeit
import tempfile
from pathlib import Path

# Generate test data
def generate_test_data(lines=100000):
    with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.log') as f:
        for i in range(lines):
            level = ['INFO', 'WARN', 'ERROR'][i % 3]
            f.write(f"2024-01-01 12:00:00 {level} Message {i}\n")
        return f.name

# Baseline: load entire file
def baseline_parser(filepath):
    with open(filepath) as f:
        lines = f.readlines()
    return sum(1 for line in lines if 'ERROR' in line)

# Optimized: streaming
def optimized_parser(filepath):
    count = 0
    with open(filepath, buffering=8192) as f:
        for line in f:
            if 'ERROR' in line:
                count += 1
    return count

if __name__ == '__main__':
    test_file = generate_test_data(100000)
    
    baseline_time = timeit.timeit(lambda: baseline_parser(test_file), number=10)
    optimized_time = timeit.timeit(lambda: optimized_parser(test_file), number=10)
    
    speedup = baseline_time / optimized_time
    
    print(f"Baseline: {baseline_time:.4f}s")
    print(f"Optimized: {optimized_time:.4f}s")
    print(f"Speedup: {speedup:.2f}x")
    
    Path(test_file).unlink()
    
    with open('results/log_parser_results.txt', 'w') as f:
        f.write(f"Baseline: {baseline_time:.4f}s\n")
        f.write(f"Optimized: {optimized_time:.4f}s\n")
        f.write(f"Speedup: {speedup:.2f}x\n")
