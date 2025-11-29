# Intentionally insecure base for the exam
FROM python:latest

WORKDIR /app
COPY . .
RUN apt-get update && apt-get install -y curl vim && rm -rf /var/lib/apt/lists/*

EXPOSE 8080
CMD ["python", "app.py"]
