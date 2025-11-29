FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app
COPY app.py .

RUN useradd --create-home appuser
USER appuser

EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s --retries=3 CMD python - <<'PY'
import http.client
conn = http.client.HTTPConnection("127.0.0.1", 8000, timeout=2)
try:
    conn.request("GET", "/health")
    resp = conn.getresponse()
    raise SystemExit(0 if resp.status == 200 else 1)
except Exception:
    raise SystemExit(1)
finally:
    conn.close()
PY

CMD ["python", "-m", "http.server", "8000"]
