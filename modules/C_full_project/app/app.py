from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import logging
import os
import socket
from datetime import datetime

logging.basicConfig(level=logging.INFO)
PORT = int(os.getenv("PORT", "8000"))
SERVICE_NAME = os.getenv("SERVICE_NAME", "devops-demo")

class Handler(BaseHTTPRequestHandler):
    def _send_json(self, payload, status=200):
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(payload).encode("utf-8"))

    def do_GET(self):
        if self.path == "/health":
            self._send_json({"status": "ok", "service": SERVICE_NAME})
        elif self.path == "/metrics":
            self._send_json({
                "service": SERVICE_NAME,
                "hostname": socket.gethostname(),
                "time": datetime.utcnow().isoformat() + "Z",
            })
        else:
            self._send_json({"error": "not found"}, status=404)

def run():
    server = HTTPServer(("0.0.0.0", PORT), Handler)
    logging.info("Starting %s on 0.0.0.0:%s", SERVICE_NAME, PORT)
    server.serve_forever()

if __name__ == "__main__":
    run()
