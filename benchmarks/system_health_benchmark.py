#!/usr/bin/env python3
import timeit
import psutil
from concurrent.futures import ThreadPoolExecutor

# Baseline: sequential checks
def baseline_health_check():
    results = []
    for _ in range(50):
        results.append(psutil.cpu_percent(interval=0.01))
        results.append(psutil.virtual_memory().percent)
        results.append(psutil.disk_usage('/').percent)
    return results

# Optimized: concurrent checks
def optimized_health_check():
    def check():
        return [
            psutil.cpu_percent(interval=0.01),
            psutil.virtual_memory().percent,
            psutil.disk_usage('/').percent
        ]
    
    with ThreadPoolExecutor(max_workers=10) as executor:
        futures = [executor.submit(check) for _ in range(50)]
        return [f.result() for f in futures]

if __name__ == '__main__':
    baseline_time = timeit.timeit(baseline_health_check, number=5)
    optimized_time = timeit.timeit(optimized_health_check, number=5)
    
    speedup = baseline_time / optimized_time
    
    print(f"Baseline: {baseline_time:.4f}s")
    print(f"Optimized: {optimized_time:.4f}s")
    print(f"Speedup: {speedup:.2f}x")
    
    with open('results/system_health_results.txt', 'w') as f:
        f.write(f"Baseline: {baseline_time:.4f}s\n")
        f.write(f"Optimized: {optimized_time:.4f}s\n")
        f.write(f"Speedup: {speedup:.2f}x\n")
