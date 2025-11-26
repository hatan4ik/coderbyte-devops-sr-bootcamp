from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
import logging
import os
from typing import Tuple


HOST = os.getenv("HOST", "0.0.0.0")
PORT = int(os.getenv("PORT", "8000"))

logging.basicConfig(
    level=os.getenv("LOG_LEVEL", "INFO"),
    format="%(asctime)s %(levelname)s %(message)s",
)


class Handler(BaseHTTPRequestHandler):
    """Simple HTTP handler with JSON responses and structured logging."""

    server_version = "exam01-http/1.0"

    def log_message(self, fmt: str, *args) -> None:
        logging.info("%s - %s", self.address_string(), fmt % args)

    def _send_json(self, payload, status: int = 200) -> None:
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):  # noqa: N802 (BaseHTTPRequestHandler signature)
        route = self._route()
        if route == ("/health", "GET"):
            self._send_json({"status": "ok"})
        else:
            self._send_json({"error": "not found"}, status=404)

    def _route(self) -> Tuple[str, str]:
        """Return normalized route tuple for simple routing."""
        path = self.path.split("?")[0]
        return (path, self.command.upper())


def run() -> None:
    server = ThreadingHTTPServer((HOST, PORT), Handler)
    logging.info("Starting server on %s:%s", HOST, PORT)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        logging.info("Shutting down gracefully")
    finally:
        server.server_close()


if __name__ == "__main__":
    run()
