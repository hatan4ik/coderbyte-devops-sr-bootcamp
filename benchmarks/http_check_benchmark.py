#!/usr/bin/env python3
import timeit
from concurrent.futures import ThreadPoolExecutor
from http.server import HTTPServer, BaseHTTPRequestHandler
from threading import Thread
import time

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
    def log_message(self, format, *args):
        pass

def start_server():
    server = HTTPServer(('localhost', 8888), Handler)
    thread = Thread(target=server.serve_forever, daemon=True)
    thread.start()
    time.sleep(0.5)
    return server

# Baseline: sequential requests
def baseline_http_check():
    import urllib.request
    for _ in range(100):
        urllib.request.urlopen('http://localhost:8888', timeout=1).read()

# Optimized: concurrent requests
def optimized_http_check():
    import urllib.request
    def check():
        return urllib.request.urlopen('http://localhost:8888', timeout=1).read()
    
    with ThreadPoolExecutor(max_workers=20) as executor:
        list(executor.map(lambda _: check(), range(100)))

if __name__ == '__main__':
    server = start_server()
    
    baseline_time = timeit.timeit(baseline_http_check, number=3)
    optimized_time = timeit.timeit(optimized_http_check, number=3)
    
    speedup = baseline_time / optimized_time
    
    print(f"Baseline: {baseline_time:.4f}s")
    print(f"Optimized: {optimized_time:.4f}s")
    print(f"Speedup: {speedup:.2f}x")
    
    server.shutdown()
    
    with open('results/http_check_results.txt', 'w') as f:
        f.write(f"Baseline: {baseline_time:.4f}s\n")
        f.write(f"Optimized: {optimized_time:.4f}s\n")
        f.write(f"Speedup: {speedup:.2f}x\n")
