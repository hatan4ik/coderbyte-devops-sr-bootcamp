#!/usr/bin/env python3
import json
import threading
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path
from typing import Tuple

from fetch import run


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):  # noqa: N802
        if self.path == "/ok":
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"ok")
        elif self.path == "/slow":
            import time
            time.sleep(0.2)
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"slow")
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, fmt, *args):  # silence
        return


def start_server() -> Tuple[HTTPServer, threading.Thread]:
    server = HTTPServer(("127.0.0.1", 0), Handler)
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    return server, thread


def test_run_summary(tmp_path: Path):
    server, thread = start_server()
    base = f"http://127.0.0.1:{server.server_port}"
    urls = [f"{base}/ok", f"{base}/missing", f"{base}/slow"]

    result = run(urls, timeout=1)

    assert result["total"] == 3
    assert result["success"] == 2  # ok + slow
    assert result["failure"] == 1  # missing
    assert len(result["results"]) == 3
    # ensure each URL present
    returned_urls = {r["url"] for r in result["results"]}
    assert set(urls) == returned_urls

    server.shutdown()
    thread.join(timeout=1)


if __name__ == "__main__":
    test_run_summary(Path("."))
    print(json.dumps({"status": "ok"}, indent=2))
