from app import health


def test_health_status_ok():
    assert health()["status"] == "ok"
