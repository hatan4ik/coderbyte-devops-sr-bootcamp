FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN apt-get update \
 && apt-get install -y --no-install-recommends gcc \
 && pip install --no-cache-dir --upgrade pip \
 && pip install --no-cache-dir -r requirements.txt \
 && apt-get purge -y gcc \
 && rm -rf /var/lib/apt/lists/*
COPY app.py .

FROM python:3.11-slim
RUN groupadd -r app && useradd -r -g app -u 1000 app
WORKDIR /app
COPY --from=builder /usr/local /usr/local
COPY --chown=app:app app.py /app/
ENV PYTHONUNBUFFERED=1
USER app
EXPOSE 8000
HEALTHCHECK CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health').read()"
CMD ["python", "app.py"]
