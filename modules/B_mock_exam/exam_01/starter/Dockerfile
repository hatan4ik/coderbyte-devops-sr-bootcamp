FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt .
RUN python -m pip install --upgrade pip && \
    python -m pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Create non-root runtime user
RUN useradd --create-home appuser
USER appuser

EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s --retries=3 CMD python - <<'PY'\nimport http.client\nconn = http.client.HTTPConnection("127.0.0.1", 8000, timeout=2)\ntry:\n    conn.request("GET", "/health")\n    resp = conn.getresponse()\n    exit(0 if resp.status == 200 else 1)\nexcept Exception:\n    exit(1)\nfinally:\n    conn.close()\nPY

CMD ["python", "app.py"]
