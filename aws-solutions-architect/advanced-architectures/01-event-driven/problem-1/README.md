# Problem 1: Event-Driven Microservices with EventBridge

**Difficulty**: 🔴 Hard (120 minutes)  
**Category**: Architecture, Event-Driven, Microservices

## Problem Statement

Design and implement an event-driven architecture for a ride-sharing platform using EventBridge:

**Services**:
1. **Ride Service**: Create/update rides
2. **Driver Service**: Assign drivers
3. **Payment Service**: Process payments
4. **Notification Service**: Send alerts
5. **Analytics Service**: Track metrics
6. **Fraud Detection**: Real-time fraud checks

**Events**:
- RideRequested
- DriverAssigned
- RideStarted
- RideCompleted
- PaymentProcessed
- PaymentFailed
- FraudDetected

**Requirements**:
- Event schema registry
- Dead letter queues
- Event replay capability
- Cross-account event routing
- Archive for compliance (7 years)
- Event filtering and transformation
- Idempotent consumers
- Circuit breaker pattern

## Architecture

```
┌─────────────┐
│ Ride Service│──┐
└─────────────┘  │
                 │  RideRequested
┌─────────────┐  │  DriverAssigned
│Driver Service├──┼──────────────────┐
└─────────────┘  │                  │
                 │              ┌───▼────────┐
┌─────────────┐  │              │ EventBridge│
│Payment Svc  ├──┤              │   Bus      │
└─────────────┘  │              └───┬────────┘
                 │                  │
┌─────────────┐  │                  │
│Notification ├──┤         ┌────────┼────────┐
└─────────────┘  │         │        │        │
                 │         ▼        ▼        ▼
┌─────────────┐  │    ┌────────┐ ┌────┐ ┌──────┐
│ Analytics   ├──┘    │ Lambda │ │SQS │ │ SNS  │
└─────────────┘       └────────┘ └────┘ └──────┘
                           │
                      ┌────▼─────┐
                      │ Archive  │
                      │ (S3)     │
                      └──────────┘
```

## Expected Deliverables

1. EventBridge bus and rules
2. Event schemas (JSON Schema)
3. Lambda consumers for each service
4. Terraform infrastructure
5. DLQ handling and retry logic
6. Monitoring and alerting
7. Load test (10K events/sec)

## Success Criteria

- All events delivered at-least-once
- Event ordering preserved per ride
- DLQ for failed processing
- Schema validation enforced
- Archive retention working
- P99 latency < 100ms
- Cost < $1000/month for 1M events/day
