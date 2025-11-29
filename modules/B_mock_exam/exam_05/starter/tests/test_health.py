import json
import sys
from pathlib import Path

# Allow running tests from repo root
ROOT = Path(__file__).resolve().parents[1]
sys.path.append(str(ROOT))

from app.app import app  # noqa: E402


def test_health_endpoint():
    client = app.test_client()
    resp = client.get("/health")
    assert resp.status_code == 200
    body = json.loads(resp.data.decode())
    assert body.get("status") == "ok"
