#!/usr/bin/env python3
"""Driver Service - Assigns drivers to rides."""

import boto3
import json
import os
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
events = boto3.client('events')

TABLE_NAME = os.environ['TABLE_NAME']
EVENT_BUS_NAME = os.environ['EVENT_BUS_NAME']

table = dynamodb.Table(TABLE_NAME)

def handler(event, context):
    """Assign driver to ride."""
    
    for record in event['Records']:
        detail = json.loads(record['body']) if 'body' in record else record['detail']
        
        ride_id = detail['rideId']
        pickup = detail['pickup']
        
        # Find nearest available driver (simplified)
        driver_id = find_nearest_driver(pickup)
        
        if driver_id:
            # Update driver status
            table.update_item(
                Key={'driverId': driver_id},
                UpdateExpression='SET #status = :status, currentRideId = :rideId',
                ExpressionAttributeNames={'#status': 'status'},
                ExpressionAttributeValues={
                    ':status': 'assigned',
                    ':rideId': ride_id
                }
            )
            
            # Publish DriverAssigned event
            events.put_events(
                Entries=[{
                    'Source': 'rideshare.drivers',
                    'DetailType': 'DriverAssigned',
                    'Detail': json.dumps({
                        'rideId': ride_id,
                        'driverId': driver_id,
                        'timestamp': datetime.now().isoformat()
                    }),
                    'EventBusName': EVENT_BUS_NAME
                }]
            )
    
    return {'statusCode': 200}

def find_nearest_driver(pickup):
    """Find nearest available driver."""
    response = table.scan(
        FilterExpression='#status = :status',
        ExpressionAttributeNames={'#status': 'status'},
        ExpressionAttributeValues={':status': 'available'}
    )
    
    if response['Items']:
        return response['Items'][0]['driverId']
    return None
