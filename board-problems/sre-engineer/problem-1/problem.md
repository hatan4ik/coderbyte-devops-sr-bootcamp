# Problem 01: Add Prometheus Metrics 🟢

**Time**: 20 min | **Points**: 50

## Scenario
Add Prometheus metrics to track golden signals.

## Given App
```python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def index():
    return "Hello"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
```

## Requirements
1. Add Prometheus client library
2. Track request count (by method, endpoint, status)
3. Track request latency (histogram)
4. Track error count
5. Expose /metrics endpoint

## Golden Signals
- **Latency**: Request duration
- **Traffic**: Requests per second
- **Errors**: Error rate
- **Saturation**: (bonus: add resource metrics)

## Success
- [ ] /metrics endpoint works
- [ ] All golden signals tracked
- [ ] Prometheus can scrape
- [ ] Metrics follow naming conventions
