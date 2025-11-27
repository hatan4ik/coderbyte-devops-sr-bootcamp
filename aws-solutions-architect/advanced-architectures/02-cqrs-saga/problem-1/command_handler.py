#!/usr/bin/env python3
"""Command Handler - Processes commands and stores events."""

import boto3
import json
import os
from datetime import datetime
from decimal import Decimal
import uuid

dynamodb = boto3.resource('dynamodb')
EVENT_STORE_TABLE = os.environ['EVENT_STORE_TABLE']
event_store = dynamodb.Table(EVENT_STORE_TABLE)

def handler(event, context):
    """Handle commands and generate events."""
    
    command_type = event['pathParameters']['command']
    body = json.loads(event['body'])
    
    if command_type == 'CreateOrder':
        return handle_create_order(body)
    elif command_type == 'AddItem':
        return handle_add_item(body)
    elif command_type == 'ConfirmOrder':
        return handle_confirm_order(body)
    elif command_type == 'CancelOrder':
        return handle_cancel_order(body)
    
    return {'statusCode': 400, 'body': json.dumps({'error': 'Unknown command'})}

def handle_create_order(data):
    """Handle CreateOrder command."""
    order_id = str(uuid.uuid4())
    customer_id = data['customerId']
    
    # Load current state (empty for new order)
    current_version = 0
    
    # Generate event
    event = {
        'aggregateId': order_id,
        'version': current_version + 1,
        'eventType': 'OrderCreated',
        'eventData': json.dumps({
            'orderId': order_id,
            'customerId': customer_id,
            'createdAt': datetime.now().isoformat()
        }),
        'timestamp': datetime.now().isoformat()
    }
    
    # Store event with optimistic concurrency
    try:
        event_store.put_item(
            Item=event,
            ConditionExpression='attribute_not_exists(aggregateId) AND attribute_not_exists(version)'
        )
    except dynamodb.meta.client.exceptions.ConditionalCheckFailedException:
        return {'statusCode': 409, 'body': json.dumps({'error': 'Concurrency conflict'})}
    
    return {
        'statusCode': 201,
        'body': json.dumps({'orderId': order_id, 'version': event['version']})
    }

def handle_add_item(data):
    """Handle AddItem command."""
    order_id = data['orderId']
    product_id = data['productId']
    quantity = data['quantity']
    price = Decimal(str(data['price']))
    
    # Load current state
    current_version = get_current_version(order_id)
    
    # Generate event
    event = {
        'aggregateId': order_id,
        'version': current_version + 1,
        'eventType': 'ItemAdded',
        'eventData': json.dumps({
            'orderId': order_id,
            'productId': product_id,
            'quantity': quantity,
            'price': float(price)
        }),
        'timestamp': datetime.now().isoformat()
    }
    
    try:
        event_store.put_item(
            Item=event,
            ConditionExpression='attribute_not_exists(version)'
        )
    except dynamodb.meta.client.exceptions.ConditionalCheckFailedException:
        return {'statusCode': 409, 'body': json.dumps({'error': 'Concurrency conflict'})}
    
    return {
        'statusCode': 200,
        'body': json.dumps({'orderId': order_id, 'version': event['version']})
    }

def handle_confirm_order(data):
    """Handle ConfirmOrder command."""
    order_id = data['orderId']
    
    # Load and validate current state
    current_state = rebuild_state(order_id)
    
    if current_state['status'] != 'draft':
        return {'statusCode': 400, 'body': json.dumps({'error': 'Order not in draft state'})}
    
    if not current_state.get('items'):
        return {'statusCode': 400, 'body': json.dumps({'error': 'Order has no items'})}
    
    current_version = current_state['version']
    
    # Generate event
    event = {
        'aggregateId': order_id,
        'version': current_version + 1,
        'eventType': 'OrderConfirmed',
        'eventData': json.dumps({
            'orderId': order_id,
            'confirmedAt': datetime.now().isoformat()
        }),
        'timestamp': datetime.now().isoformat()
    }
    
    try:
        event_store.put_item(
            Item=event,
            ConditionExpression='attribute_not_exists(version)'
        )
    except dynamodb.meta.client.exceptions.ConditionalCheckFailedException:
        return {'statusCode': 409, 'body': json.dumps({'error': 'Concurrency conflict'})}
    
    return {
        'statusCode': 200,
        'body': json.dumps({'orderId': order_id, 'version': event['version']})
    }

def handle_cancel_order(data):
    """Handle CancelOrder command."""
    order_id = data['orderId']
    reason = data.get('reason', 'Customer request')
    
    current_version = get_current_version(order_id)
    
    event = {
        'aggregateId': order_id,
        'version': current_version + 1,
        'eventType': 'OrderCancelled',
        'eventData': json.dumps({
            'orderId': order_id,
            'reason': reason,
            'cancelledAt': datetime.now().isoformat()
        }),
        'timestamp': datetime.now().isoformat()
    }
    
    try:
        event_store.put_item(
            Item=event,
            ConditionExpression='attribute_not_exists(version)'
        )
    except dynamodb.meta.client.exceptions.ConditionalCheckFailedException:
        return {'statusCode': 409, 'body': json.dumps({'error': 'Concurrency conflict'})}
    
    return {
        'statusCode': 200,
        'body': json.dumps({'orderId': order_id, 'version': event['version']})
    }

def get_current_version(aggregate_id):
    """Get current version of aggregate."""
    response = event_store.query(
        KeyConditionExpression='aggregateId = :id',
        ExpressionAttributeValues={':id': aggregate_id},
        ScanIndexForward=False,
        Limit=1
    )
    
    if response['Items']:
        return int(response['Items'][0]['version'])
    return 0

def rebuild_state(aggregate_id):
    """Rebuild aggregate state from events."""
    response = event_store.query(
        KeyConditionExpression='aggregateId = :id',
        ExpressionAttributeValues={':id': aggregate_id},
        ScanIndexForward=True
    )
    
    state = {
        'orderId': aggregate_id,
        'status': 'draft',
        'items': [],
        'version': 0
    }
    
    for event in response['Items']:
        event_type = event['eventType']
        event_data = json.loads(event['eventData'])
        
        if event_type == 'OrderCreated':
            state['customerId'] = event_data['customerId']
            state['createdAt'] = event_data['createdAt']
        elif event_type == 'ItemAdded':
            state['items'].append({
                'productId': event_data['productId'],
                'quantity': event_data['quantity'],
                'price': event_data['price']
            })
        elif event_type == 'OrderConfirmed':
            state['status'] = 'confirmed'
            state['confirmedAt'] = event_data['confirmedAt']
        elif event_type == 'OrderCancelled':
            state['status'] = 'cancelled'
            state['cancelledAt'] = event_data['cancelledAt']
        
        state['version'] = int(event['version'])
    
    return state
