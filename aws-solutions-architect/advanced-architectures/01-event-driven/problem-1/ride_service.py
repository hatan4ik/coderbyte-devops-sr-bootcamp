#!/usr/bin/env python3
"""Ride Service - Publishes RideRequested events."""

import boto3
import json
import os
from datetime import datetime
from decimal import Decimal
import uuid

dynamodb = boto3.resource('dynamodb')
events = boto3.client('events')

TABLE_NAME = os.environ['TABLE_NAME']
EVENT_BUS_NAME = os.environ['EVENT_BUS_NAME']

table = dynamodb.Table(TABLE_NAME)

def handler(event, context):
    """Handle ride creation and publish event."""
    
    # Parse request
    body = json.loads(event.get('body', '{}'))
    
    ride_id = str(uuid.uuid4())
    customer_id = body['customerId']
    pickup = body['pickup']
    dropoff = body['dropoff']
    
    # Store ride with idempotency key
    idempotency_key = event.get('headers', {}).get('Idempotency-Key', ride_id)
    
    try:
        table.put_item(
            Item={
                'rideId': ride_id,
                'customerId': customer_id,
                'pickup': pickup,
                'dropoff': dropoff,
                'status': 'requested',
                'createdAt': datetime.now().isoformat(),
                'idempotencyKey': idempotency_key
            },
            ConditionExpression='attribute_not_exists(idempotencyKey)'
        )
    except dynamodb.meta.client.exceptions.ConditionalCheckFailedException:
        # Idempotent - already processed
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Already processed', 'rideId': ride_id})
        }
    
    # Publish RideRequested event
    events.put_events(
        Entries=[{
            'Source': 'rideshare.rides',
            'DetailType': 'RideRequested',
            'Detail': json.dumps({
                'rideId': ride_id,
                'customerId': customer_id,
                'pickup': pickup,
                'dropoff': dropoff,
                'timestamp': datetime.now().isoformat()
            }),
            'EventBusName': EVENT_BUS_NAME
        }]
    )
    
    return {
        'statusCode': 201,
        'body': json.dumps({'rideId': ride_id})
    }
