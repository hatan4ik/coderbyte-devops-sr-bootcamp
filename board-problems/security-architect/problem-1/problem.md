# Problem 01: Non-Root Container 🟢

**Time**: 15 min | **Points**: 50

## Given Dockerfile
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY app.py .
RUN pip install flask
EXPOSE 8000
CMD ["python", "app.py"]
```

## Requirements
1. Create user UID 1000
2. Set file ownership
3. Run as non-root

## Success Criteria
- [ ] Runs as UID 1000
- [ ] App functional
- [ ] No root processes
