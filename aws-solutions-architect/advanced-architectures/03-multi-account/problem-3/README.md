# Problem 3: Centralized Logging with CloudWatch

**Difficulty**: 🟡 Medium (60 minutes)  
**Category**: Multi-Account, Logging, Observability

## Problem Statement

Implement centralized logging for 50+ accounts:

**Requirements**:
- CloudWatch Logs aggregation
- Cross-account log subscriptions
- Kinesis for streaming
- S3 for long-term storage
- Athena for queries
- Cost < $5000/month

**Components**:
- CloudWatch Logs (all accounts)
- Kinesis Data Firehose
- S3 data lake
- Glue Catalog
- Athena queries

## Architecture

```
Member Accounts → CloudWatch Logs → Kinesis → S3 → Athena
                                       ↓
                                  Real-time Processing
```
