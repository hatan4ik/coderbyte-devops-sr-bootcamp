# Problem 03: Implement SLO-Based Alerting 🟡

**Time**: 45 min | **Difficulty**: Medium | **Points**: 120

## Scenario
Implement SLO monitoring with error budget tracking and burn rate alerts.

## Requirements
1. Define SLIs (latency, availability, error rate)
2. Set SLOs (99.9% availability, p95 < 500ms)
3. Calculate error budgets
4. Create burn rate alerts (fast/slow)
5. Build Grafana dashboard

## SLO Targets
- **Availability**: 99.9% (43 min downtime/month)
- **Latency**: p95 < 500ms, p99 < 1s
- **Error Rate**: < 0.1%

## Deliverables
```
solution/
├── app.py (instrumented)
├── prometheus-rules.yaml
├── grafana-dashboard.json
└── README.md
```

## Success Criteria
- [ ] SLIs tracked
- [ ] Error budget calculated
- [ ] Burn rate alerts configured
- [ ] Dashboard shows SLO status
