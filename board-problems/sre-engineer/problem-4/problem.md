# Problem 4 – Log Aggregation Pipeline

**Objective**: Create a centralized log pipeline (e.g., Fluent Bit → Loki/ELK) with retention and querying.

## Requirements
- Collect app logs from Kubernetes nodes/pods.
- Parse/label logs for service, severity, and trace correlation.
- Configure retention and cost-aware storage tiers.
- Provide sample queries and validation steps.

## Deliverables
- Pipeline configuration (Fluent Bit/Fluentd/Filebeat + backend).
- README with deployment steps and sample queries.
