#!/usr/bin/env python3
"""Flask API with health endpoint."""
from flask import Flask, jsonify
import logging
import os

logging.basicConfig(level=os.getenv('LOG_LEVEL', 'INFO'))
app = Flask(__name__)

@app.route('/health')
def health():
    return jsonify({"status": "ok"}), 200

@app.route('/')
def index():
    return jsonify({"service": "exam05-api", "endpoints": ["/health"]}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
