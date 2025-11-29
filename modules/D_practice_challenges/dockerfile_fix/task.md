# Challenge: Fix the Dockerfile

You are given a naive Dockerfile:

```dockerfile
FROM ubuntu:latest
COPY . .
RUN pip install -r requirements.txt
CMD python app.py
```

Problems:

- Heavy base image
- No working directory
- No pinning or cache optimizations
- No non-root user

Write an improved Dockerfile in `Dockerfile` that:

- Uses `python:3.10-slim`
- Sets `WORKDIR /app`
- Copies `requirements.txt` then installs
- Copies application code
- Uses a non-root user `appuser`
