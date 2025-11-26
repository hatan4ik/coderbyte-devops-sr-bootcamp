from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
import logging
import os
import uuid
from typing import Dict, Tuple


HOST = os.getenv("HOST", "0.0.0.0")
PORT = int(os.getenv("PORT", "8000"))

logging.basicConfig(
    level=os.getenv("LOG_LEVEL", "INFO"),
    format="%(asctime)s %(levelname)s %(message)s",
)


SERVICE_NAME = os.getenv("SERVICE_NAME", "exam01-http")


class Handler(BaseHTTPRequestHandler):
    """Simple HTTP handler with JSON responses and structured logging."""

    server_version = f"{SERVICE_NAME}/1.0"

    def log_message(self, fmt: str, *args) -> None:
        logging.info("%s - %s", self.address_string(), fmt % args)

    def _send_json(self, payload, status: int = 200, headers: Dict[str, str] = None) -> None:
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        for key, value in (headers or {}).items():
            self.send_header(key, value)
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):  # noqa: N802 (BaseHTTPRequestHandler signature)
        request_id = uuid.uuid4().hex
        route = self._route()
        logging.info("request_id=%s method=%s path=%s", request_id, self.command, self.path)

        if route == ("/health", "GET"):
            payload = {"status": "ok", "service": SERVICE_NAME}
            self._send_json(payload, headers={"X-Request-Id": request_id})
            return

        if route == ("/", "GET"):
            payload = {"service": SERVICE_NAME, "endpoints": ["/health"]}
            self._send_json(payload, headers={"X-Request-Id": request_id})
            return

        self._send_json({"error": "not found"}, status=404, headers={"X-Request-Id": request_id})

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
