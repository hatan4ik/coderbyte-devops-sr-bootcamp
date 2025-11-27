# Problem 1: Order Processing Saga with Step Functions

**Difficulty**: 🔴 Hard (90 minutes)  
**Category**: Serverless, Orchestration, Distributed Transactions

## Problem Statement

Implement a distributed transaction (Saga pattern) for e-commerce order processing using Step Functions:

**Workflow Steps**:
1. Validate order (inventory, pricing)
2. Reserve inventory
3. Process payment
4. Create shipment
5. Send confirmation email
6. Update analytics

**Requirements**:
- Compensating transactions for rollback
- Parallel execution where possible
- Error handling and retries
- Dead letter queue for failures
- Idempotency for all operations
- Distributed tracing with X-Ray
- Cost < $0.01 per order

**Failure Scenarios**:
- Payment declined → Release inventory
- Shipment failed → Refund payment, release inventory
- Email failed → Retry 3x, then DLQ (don't block order)

## Architecture

```
Start → Validate → Reserve Inventory ──┐
                                        ├→ Process Payment → Create Shipment → Email
                                        │                                        ↓
                                        └──────────────────────────────────→ Analytics
                                        
Failure Path:
Payment Failed → Release Inventory → Notify Customer
Shipment Failed → Refund Payment → Release Inventory → Notify Customer
```

## Expected Deliverables

1. Step Functions state machine (ASL JSON)
2. Lambda functions for each step
3. Terraform for infrastructure
4. Error handling and compensation logic
5. Load test (1000 orders/sec)
6. Cost analysis

## Success Criteria

- 99.9% success rate for valid orders
- Automatic rollback on failures
- No orphaned reservations
- All operations idempotent
- P99 latency < 5 seconds
- Cost under budget
