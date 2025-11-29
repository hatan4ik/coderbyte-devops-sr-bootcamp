#!/usr/bin/env python3
"""Payment Service - Processes payments for completed rides."""

import boto3
import json
import os
from datetime import datetime
from decimal import Decimal

events = boto3.client('events')
EVENT_BUS_NAME = os.environ['EVENT_BUS_NAME']

def handler(event, context):
    """Process payment for completed ride."""
    
    for record in event['Records']:
        detail = json.loads(record['body']) if 'body' in record else record['detail']
        
        ride_id = detail['rideId']
        amount = Decimal(str(detail.get('amount', 25.00)))
        customer_id = detail['customerId']
        
        # Process payment (simplified - would call payment gateway)
        payment_success = process_payment(customer_id, amount)
        
        if payment_success:
            events.put_events(
                Entries=[{
                    'Source': 'rideshare.payments',
                    'DetailType': 'PaymentProcessed',
                    'Detail': json.dumps({
                        'rideId': ride_id,
                        'customerId': customer_id,
                        'amount': float(amount),
                        'timestamp': datetime.now().isoformat()
                    }),
                    'EventBusName': EVENT_BUS_NAME
                }]
            )
        else:
            events.put_events(
                Entries=[{
                    'Source': 'rideshare.payments',
                    'DetailType': 'PaymentFailed',
                    'Detail': json.dumps({
                        'rideId': ride_id,
                        'customerId': customer_id,
                        'reason': 'Insufficient funds',
                        'timestamp': datetime.now().isoformat()
                    }),
                    'EventBusName': EVENT_BUS_NAME
                }]
            )
    
    return {'statusCode': 200}

def process_payment(customer_id, amount):
    """Process payment via payment gateway."""
    # Simulate payment processing
    return True
