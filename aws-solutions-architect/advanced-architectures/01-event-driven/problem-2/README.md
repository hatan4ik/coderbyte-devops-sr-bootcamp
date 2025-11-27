# Problem 2: Event-Driven Data Pipeline with Kinesis

**Difficulty**: 🔴 Hard (90 minutes)  
**Category**: Event-Driven, Real-Time Processing, Analytics

## Problem Statement

Build real-time clickstream analytics pipeline:

**Requirements**:
- Ingest 100K events/second
- Real-time aggregation (1-minute windows)
- Anomaly detection
- Data lake storage (S3)
- Real-time dashboards
- Cost < $2000/month

**Components**:
- Kinesis Data Streams
- Kinesis Data Analytics
- Lambda for processing
- DynamoDB for aggregates
- S3 for data lake
- QuickSight for visualization

## Architecture

```
Web/Mobile → API Gateway → Kinesis Stream → Analytics → DynamoDB
                                    ↓                      ↓
                              Firehose → S3 → Athena → QuickSight
```
