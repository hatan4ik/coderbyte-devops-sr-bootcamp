# Exam 07 - SRE & Observability

## Overview
Production-grade observability with Prometheus metrics, alerts, and SLO monitoring.

## Metrics Exposed

### Golden Signals
- **Latency**: `http_request_duration_seconds` (histogram)
- **Traffic**: `http_requests_total` (counter)
- **Errors**: `http_errors_total` (counter)
- **Saturation**: CPU/memory via node_exporter

### Labels
- `method`: HTTP method
- `endpoint`: Request path
- `status`: HTTP status code

## Local Development

### Run Application
```bash
pip install flask prometheus-client
python app/app.py

# Test metrics
curl http://localhost:8000/metrics
curl http://localhost:8000/healthz
```

### Run with Prometheus
```bash
# docker-compose.yml
version: '3'
services:
  app:
    build: .
    ports: ["8000:8000"]
  
  prometheus:
    image: prom/prometheus:latest
    ports: ["9090:9090"]
    volumes:
      - ./observability:/etc/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'

# Start
docker-compose up
```

## Grafana Dashboard

### Panels to Create

1. **Request Rate (RPS)**
   ```promql
   sum(rate(http_requests_total[5m])) by (service)
   ```

2. **P95 Latency**
   ```promql
   histogram_quantile(0.95, 
     sum(rate(http_request_duration_seconds_bucket[5m])) by (le)
   )
   ```

3. **Error Rate**
   ```promql
   sum(rate(http_errors_total[5m])) / sum(rate(http_requests_total[5m]))
   ```

4. **Status Code Distribution**
   ```promql
   sum(rate(http_requests_total[5m])) by (status)
   ```

## Alert Rules

### HighErrorRate
- **Threshold**: >5% error rate
- **Duration**: 5 minutes
- **Severity**: Critical
- **Action**: Page on-call engineer

### HighLatency
- **Threshold**: P95 > 1 second
- **Duration**: 10 minutes
- **Severity**: Warning
- **Action**: Investigate performance

### ServiceDown
- **Threshold**: Service unreachable
- **Duration**: 2 minutes
- **Severity**: Critical
- **Action**: Immediate response

## SLO Definition

### Availability SLO
- **Target**: 99.9% uptime
- **Error Budget**: 43 minutes/month
- **Measurement**: `up` metric

### Latency SLO
- **Target**: P95 < 500ms
- **Error Budget**: 0.1% of requests
- **Measurement**: `http_request_duration_seconds`

## Runbook

### High Error Rate Alert

1. **Check dashboard** - Identify affected endpoints
2. **Review logs** - Look for error patterns
3. **Check dependencies** - Database, cache, external APIs
4. **Rollback** - If recent deployment
5. **Scale** - If capacity issue

### High Latency Alert

1. **Check resource usage** - CPU, memory, disk I/O
2. **Review slow queries** - Database performance
3. **Check external calls** - Third-party API latency
4. **Scale horizontally** - Add more pods
5. **Optimize** - Profile and fix bottlenecks

## Production Deployment

```yaml
# Kubernetes annotations for Prometheus
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "8000"
  prometheus.io/path: "/metrics"
```

## Testing Alerts

```bash
# Generate errors
for i in {1..100}; do curl http://localhost:8000/nonexistent; done

# Generate load
ab -n 10000 -c 100 http://localhost:8000/

# Check Prometheus
open http://localhost:9090/alerts
```
