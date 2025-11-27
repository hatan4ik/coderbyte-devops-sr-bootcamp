FROM python:3.11-slim
RUN groupadd -r app && useradd -r -g app -u 1000 app
WORKDIR /app
COPY --chown=app:app app.py .
RUN pip install --no-cache-dir flask
USER app
EXPOSE 8000
CMD ["python", "app.py"]
