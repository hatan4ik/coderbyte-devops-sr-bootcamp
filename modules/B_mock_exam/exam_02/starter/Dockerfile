FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app
COPY log_processor.py .

RUN useradd --create-home appuser
USER appuser

ENTRYPOINT ["python", "log_processor.py"]
CMD ["access.log"]
