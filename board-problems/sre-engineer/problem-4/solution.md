# Solution – Log Aggregation Pipeline

## Approach
- Centralize logs with structured labels, retention, and querying.

## Steps
- Collect with Fluent Bit/Fluentd/Filebeat; label service/env/trace IDs.
- Choose backend (Loki/ELK); configure retention and tiered storage.
- Provide saved queries and alerts on error spikes; secure access with RBAC.

## Validation
- Deploy pipeline; ingest sample logs; run saved queries.
- Verify retention/tiering; alerts fire on simulated errors.
