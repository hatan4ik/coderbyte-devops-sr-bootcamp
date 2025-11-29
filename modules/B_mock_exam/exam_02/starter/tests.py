import json
from pathlib import Path

from log_processor import process_log


def test_process_log_counts_status_codes(tmp_path: Path):
    sample = tmp_path / "access.log"
    sample.write_text(
        '127.0.0.1 - - [10/Nov/2024:10:00:00 +0000] "GET /health HTTP/1.1" 200 12\n'
        '127.0.0.1 - - [10/Nov/2024:10:00:01 +0000] "GET /missing HTTP/1.1" 404 0\n'
        '127.0.0.1 - - [10/Nov/2024:10:00:02 +0000] "POST / HTTP/1.1" 500 0\n'
    )

    result = process_log(str(sample))
    assert result == {"200": 1, "404": 1, "500": 1}


if __name__ == "__main__":
    test_process_log_counts_status_codes(Path(".").resolve())
    print(json.dumps({"status": "ok"}, indent=2))
