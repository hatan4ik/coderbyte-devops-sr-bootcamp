# Problem 1: Multi-Region Active-Active Architecture

**Difficulty**: 🔴 Hard (120 minutes)  
**Category**: Disaster Recovery, High Availability, Multi-Region

## Problem Statement

Design and implement a multi-region active-active architecture for a global SaaS platform:

**Requirements**:
- 3 regions: us-east-1, eu-west-1, ap-southeast-1
- Active-active (all regions serve traffic)
- RTO: < 1 minute
- RPO: < 5 seconds
- Global load balancing with health checks
- Data replication across regions
- Conflict resolution for writes
- Automated failover
- Cost-optimized (no idle resources)

**Components**:
- Application tier (ECS Fargate)
- Database (Aurora Global Database)
- Cache (ElastiCache Global Datastore)
- Storage (S3 with CRR)
- CDN (CloudFront)
- DNS (Route 53)

**Challenges**:
- Write conflicts in multi-master setup
- Data consistency vs availability
- Network latency between regions
- Cost of data transfer
- Monitoring and alerting

## Architecture

```
                    ┌──────────────┐
                    │  Route 53    │
                    │ (Geoproximity)│
                    └──────┬───────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
   ┌────▼─────┐      ┌────▼─────┐      ┌────▼─────┐
   │us-east-1 │      │eu-west-1 │      │ap-south-1│
   └────┬─────┘      └────┬─────┘      └────┬─────┘
        │                 │                  │
   ┌────▼─────┐      ┌────▼─────┐      ┌────▼─────┐
   │CloudFront│      │CloudFront│      │CloudFront│
   └────┬─────┘      └────┬─────┘      └────┬─────┘
        │                 │                  │
   ┌────▼─────┐      ┌────▼─────┐      ┌────▼─────┐
   │   ALB    │      │   ALB    │      │   ALB    │
   └────┬─────┘      └────┬─────┘      └────┬─────┘
        │                 │                  │
   ┌────▼─────┐      ┌────▼─────┐      ┌────▼─────┐
   │ECS Fargate│     │ECS Fargate│     │ECS Fargate│
   └────┬─────┘      └────┬─────┘      └────┬─────┘
        │                 │                  │
        └─────────────────┼──────────────────┘
                          │
                  ┌───────▼────────┐
                  │ Aurora Global  │
                  │   Database     │
                  │ (Multi-Master) │
                  └────────────────┘
```

## Expected Deliverables

1. Terraform for multi-region infrastructure
2. Aurora Global Database setup
3. Route 53 health checks and routing
4. Application deployment automation
5. Data replication monitoring
6. Failover testing scripts
7. Cost analysis
8. DR runbook

## Success Criteria

- All regions serving traffic simultaneously
- Automatic failover < 1 minute
- Data loss < 5 seconds
- Write conflicts handled gracefully
- Health checks detecting failures
- Monitoring across all regions
- Cost optimized with no idle resources
