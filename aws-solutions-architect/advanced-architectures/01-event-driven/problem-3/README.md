# Problem 3: Saga Orchestration with Step Functions

**Difficulty**: 🔴 Hard (90 minutes)  
**Category**: Event-Driven, Saga Pattern, Distributed Transactions

## Problem Statement

Implement Saga pattern for travel booking system:

**Workflow**:
1. Reserve flight
2. Reserve hotel
3. Reserve car rental
4. Process payment
5. Send confirmation

**Compensation** (on failure):
- Cancel car rental
- Cancel hotel
- Cancel flight
- Refund payment

**Requirements**:
- Step Functions for orchestration
- Lambda for each service
- DynamoDB for state
- SNS for notifications
- Idempotent operations
- Timeout handling

## Architecture

```
Step Functions (Orchestrator)
    ├── Reserve Flight → Compensate
    ├── Reserve Hotel → Compensate
    ├── Reserve Car → Compensate
    └── Payment → Refund
```
