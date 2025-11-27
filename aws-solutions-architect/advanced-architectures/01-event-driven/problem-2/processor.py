#!/usr/bin/env python3
"""Real-time clickstream processor with aggregation."""

import boto3
import json
import os
from datetime import datetime
from collections import defaultdict

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['AGGREGATES_TABLE'])

def handler(event, context):
    """Process Kinesis records and aggregate metrics."""
    
    aggregates = defaultdict(lambda: {'count': 0, 'unique_users': set()})
    
    for record in event['Records']:
        payload = json.loads(record['kinesis']['data'])
        
        event_type = payload['event_type']
        user_id = payload['user_id']
        timestamp = int(payload['timestamp'])
        
        # 1-minute window
        window_key = f"{event_type}#{timestamp // 60}"
        
        aggregates[window_key]['count'] += 1
        aggregates[window_key]['unique_users'].add(user_id)
    
    # Write aggregates to DynamoDB
    for window_key, data in aggregates.items():
        table.put_item(
            Item={
                'windowKey': window_key,
                'timestamp': int(datetime.now().timestamp()),
                'count': data['count'],
                'unique_users': len(data['unique_users']),
                'expiresAt': int(datetime.now().timestamp()) + 86400
            }
        )
    
    return {'statusCode': 200}
