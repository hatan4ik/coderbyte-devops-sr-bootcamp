#!/usr/bin/env python3
"""Concurrency Basics - Threading and multiprocessing examples"""

import threading
import multiprocessing
import time
import requests
import sys

def worker_task(task_id, duration=1):
    """Simulate work"""
    print(f"Task {task_id} starting...")
    time.sleep(duration)
    print(f"Task {task_id} completed")
    return f"Result from task {task_id}"

def fetch_url(url):
    """Fetch URL for concurrent testing"""
    try:
        response = requests.get(url, timeout=5)
        return f"{url}: {response.status_code}"
    except Exception as e:
        return f"{url}: Error - {e}"

def demo_threading():
    print("=== Threading Demo ===")
    start_time = time.time()
    
    threads = []
    for i in range(5):
        thread = threading.Thread(target=worker_task, args=(i, 1))
        threads.append(thread)
        thread.start()
    
    for thread in threads:
        thread.join()
    
    print(f"Threading completed in {time.time() - start_time:.2f}s\n")

def demo_multiprocessing():
    print("=== Multiprocessing Demo ===")
    start_time = time.time()
    
    with multiprocessing.Pool(processes=3) as pool:
        tasks = [(i, 1) for i in range(5)]
        results = pool.starmap(worker_task, tasks)
    
    print(f"Multiprocessing completed in {time.time() - start_time:.2f}s\n")

def demo_concurrent_requests():
    print("=== Concurrent HTTP Requests ===")
    urls = [
        "https://httpbin.org/delay/1",
        "https://httpbin.org/status/200",
        "https://httpbin.org/json"
    ]
    
    start_time = time.time()
    
    with multiprocessing.Pool(processes=3) as pool:
        results = pool.map(fetch_url, urls)
    
    for result in results:
        print(f"  {result}")
    
    print(f"Concurrent requests completed in {time.time() - start_time:.2f}s")

if __name__ == "__main__":
    demo_threading()
    demo_multiprocessing()
    demo_concurrent_requests()