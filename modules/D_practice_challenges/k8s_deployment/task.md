# Challenge: Fix Kubernetes Deployment

You are given a broken Deployment manifest (missing selector):

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
spec:
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
      - name: api
        image: example/api:latest
```

Fix it in `deployment.yaml` so that:

- It has a proper `selector.matchLabels`.
- It runs 3 replicas.
- It exposes container port 8080.
