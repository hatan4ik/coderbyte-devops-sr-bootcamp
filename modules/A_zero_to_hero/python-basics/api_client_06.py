#!/usr/bin/env python3
"""API Client - Make HTTP requests and handle responses"""

import requests
import json
import sys

def api_request(url, method='GET', data=None):
    if not url:
        print("Usage: python api_client_06.py <url> [method] [json_data]")
        return
    
    try:
        if method.upper() == 'POST' and data:
            response = requests.post(url, json=json.loads(data), timeout=10)
        else:
            response = requests.get(url, timeout=10)
        
        print(f"Status Code: {response.status_code}")
        print(f"Response Time: {response.elapsed.total_seconds():.2f}s")
        
        try:
            json_data = response.json()
            print("Response (JSON):")
            print(json.dumps(json_data, indent=2))
        except json.JSONDecodeError:
            print("Response (Text):")
            print(response.text[:500])
            
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")

if __name__ == "__main__":
    args = sys.argv[1:]
    api_request(
        args[0] if len(args) > 0 else None,
        args[1] if len(args) > 1 else 'GET',
        args[2] if len(args) > 2 else None
    )