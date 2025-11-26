FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app
COPY app.py .

# Create non-root user
RUN useradd --create-home appuser
USER appuser

EXPOSE 8000
CMD ["python", "app.py"]
