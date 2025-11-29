# Problem 1: CQRS with Event Sourcing for E-Commerce

**Difficulty**: 🔴 Hard (120 minutes)  
**Category**: Architecture, CQRS, Event Sourcing

## Problem Statement

Implement CQRS (Command Query Responsibility Segregation) with Event Sourcing for an e-commerce order system:

**Commands** (Write Side):
- CreateOrder
- AddItem
- RemoveItem
- ApplyDiscount
- ConfirmOrder
- CancelOrder

**Queries** (Read Side):
- GetOrderById
- GetOrdersByCustomer
- GetOrderHistory
- GetInventoryStatus
- GetRevenueReport

**Requirements**:
- Event store (DynamoDB)
- Command handlers (Lambda)
- Event projections to read models
- Eventual consistency
- Event replay capability
- Snapshots for performance
- Optimistic concurrency control

## Architecture

```
Commands → Command Handler → Event Store → Event Stream
                                              ↓
                                         Projectors
                                              ↓
                                    Read Models (DynamoDB)
                                              ↓
                                         Query API
```

## Expected Deliverables

1. Event store schema
2. Command handlers (Lambda)
3. Event projectors
4. Read model schemas
5. Terraform infrastructure
6. Event replay script
7. Load test
