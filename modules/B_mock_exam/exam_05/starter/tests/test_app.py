"""Unit tests for Flask API."""
import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'app'))

from app import app
import pytest

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_health_endpoint(client):
    """Test health endpoint returns 200 and correct JSON."""
    response = client.get('/health')
    assert response.status_code == 200
    assert response.json == {"status": "ok"}

def test_index_endpoint(client):
    """Test index endpoint."""
    response = client.get('/')
    assert response.status_code == 200
    assert "service" in response.json
    assert "endpoints" in response.json
