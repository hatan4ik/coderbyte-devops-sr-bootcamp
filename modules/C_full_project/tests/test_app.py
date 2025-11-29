#!/usr/bin/env python3
"""Tests for the application."""

import json
import sys
import os
from http.client import HTTPConnection

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'app'))

def test_health_endpoint():
    """Test health endpoint returns 200 and correct JSON."""
    conn = HTTPConnection('localhost', 8000)
    conn.request('GET', '/health')
    response = conn.getresponse()
    
    assert response.status == 200
    data = json.loads(response.read().decode())
    assert data['status'] == 'healthy'
    assert 'service' in data
    conn.close()

def test_ready_endpoint():
    """Test readiness endpoint."""
    conn = HTTPConnection('localhost', 8000)
    conn.request('GET', '/ready')
    response = conn.getresponse()
    
    assert response.status == 200
    data = json.loads(response.read().decode())
    assert data['status'] == 'ready'
    conn.close()

def test_metrics_endpoint():
    """Test metrics endpoint returns valid data."""
    conn = HTTPConnection('localhost', 8000)
    conn.request('GET', '/metrics')
    response = conn.getresponse()
    
    assert response.status == 200
    data = json.loads(response.read().decode())
    assert 'uptime_seconds' in data
    assert 'requests_total' in data
    conn.close()

def test_not_found():
    """Test 404 for unknown endpoints."""
    conn = HTTPConnection('localhost', 8000)
    conn.request('GET', '/unknown')
    response = conn.getresponse()
    
    assert response.status == 404
    conn.close()

if __name__ == '__main__':
    print("Run tests with: pytest test_app.py")
