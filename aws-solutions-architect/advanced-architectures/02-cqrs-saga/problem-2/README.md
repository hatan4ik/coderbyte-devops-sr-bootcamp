# Problem 2: Banking System with Event Sourcing

**Difficulty**: 🔴 Hard (120 minutes)  
**Category**: CQRS, Event Sourcing, Financial Systems

## Problem Statement

Build banking system with complete audit trail:

**Commands**:
- OpenAccount
- Deposit
- Withdraw
- Transfer
- CloseAccount

**Queries**:
- GetBalance
- GetTransactionHistory
- GetAccountStatement
- DetectFraud

**Requirements**:
- Immutable event log
- Account snapshots every 100 events
- Regulatory compliance (7 years)
- Optimistic locking
- Idempotent operations
- Real-time fraud detection

## Architecture

```
Commands → Validator → Event Store → Projector → Balance View
                            ↓                        ↓
                       Snapshot Store          Fraud Detection
```
