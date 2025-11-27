#!/usr/bin/env python3
"""Fraud Detection Service - Real-time fraud checks."""

import boto3
import json
import os
from datetime import datetime

events = boto3.client('events')
EVENT_BUS_NAME = os.environ['EVENT_BUS_NAME']

def handler(event, context):
    """Detect fraud in ride requests."""
    
    for record in event['Records']:
        detail = json.loads(record['body']) if 'body' in record else record['detail']
        
        ride_id = detail['rideId']
        customer_id = detail['customerId']
        
        # Run fraud detection algorithms
        fraud_score = calculate_fraud_score(detail)
        
        if fraud_score > 0.8:
            # High fraud risk
            events.put_events(
                Entries=[{
                    'Source': 'rideshare.fraud',
                    'DetailType': 'FraudDetected',
                    'Detail': json.dumps({
                        'rideId': ride_id,
                        'customerId': customer_id,
                        'fraudScore': fraud_score,
                        'reason': 'Suspicious pattern detected',
                        'timestamp': datetime.now().isoformat()
                    }),
                    'EventBusName': EVENT_BUS_NAME
                }]
            )
    
    return {'statusCode': 200}

def calculate_fraud_score(detail):
    """Calculate fraud risk score."""
    score = 0.0
    
    # Check for suspicious patterns
    pickup = detail.get('pickup', {})
    dropoff = detail.get('dropoff', {})
    
    # Same pickup/dropoff
    if pickup == dropoff:
        score += 0.5
    
    # High-risk location
    if is_high_risk_location(pickup):
        score += 0.3
    
    return min(score, 1.0)

def is_high_risk_location(location):
    """Check if location is high-risk."""
    return False
