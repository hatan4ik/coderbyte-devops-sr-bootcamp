# Problem 1: Optimize Bloated Dockerfile 🟡

**Difficulty**: Medium | **Time**: 30 min | **Points**: 100

## Scenario
You've inherited a Dockerfile that's 1.8GB and takes 10 minutes to build.

## Given Code
```dockerfile
FROM ubuntu:latest
RUN apt-get update
RUN apt-get install -y python3 python3-pip git curl wget vim build-essential
WORKDIR /app
COPY . .
RUN pip3 install flask gunicorn requests
EXPOSE 8000
CMD python3 app.py
```

## Requirements
1. Reduce to <200MB
2. Run as non-root (UID 1000)
3. Add health check
4. Multi-stage build
5. Build time <3 min

## Success Criteria
- [ ] Size <200MB
- [ ] Non-root user
- [ ] Health check works
- [ ] No build tools in final image
