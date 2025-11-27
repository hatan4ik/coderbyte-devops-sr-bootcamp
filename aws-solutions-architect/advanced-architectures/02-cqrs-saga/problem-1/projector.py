#!/usr/bin/env python3
"""Event Projector - Projects events to read models."""

import boto3
import json
import os
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
ORDERS_TABLE = os.environ['ORDERS_TABLE']
INVENTORY_TABLE = os.environ['INVENTORY_TABLE']

orders_table = dynamodb.Table(ORDERS_TABLE)
inventory_table = dynamodb.Table(INVENTORY_TABLE)

def handler(event, context):
    """Project events to read models."""
    
    for record in event['Records']:
        if record['eventName'] == 'INSERT':
            new_image = record['dynamodb']['NewImage']
            
            event_type = new_image['eventType']['S']
            event_data = json.loads(new_image['eventData']['S'])
            
            if event_type == 'OrderCreated':
                project_order_created(event_data)
            elif event_type == 'ItemAdded':
                project_item_added(event_data)
            elif event_type == 'OrderConfirmed':
                project_order_confirmed(event_data)
            elif event_type == 'OrderCancelled':
                project_order_cancelled(event_data)
    
    return {'statusCode': 200}

def project_order_created(data):
    """Project OrderCreated event."""
    orders_table.put_item(
        Item={
            'orderId': data['orderId'],
            'customerId': data['customerId'],
            'status': 'draft',
            'items': [],
            'totalAmount': Decimal('0'),
            'createdAt': data['createdAt']
        }
    )

def project_item_added(data):
    """Project ItemAdded event."""
    order_id = data['orderId']
    
    # Get current order
    response = orders_table.get_item(Key={'orderId': order_id})
    order = response['Item']
    
    # Add item
    order['items'].append({
        'productId': data['productId'],
        'quantity': data['quantity'],
        'price': Decimal(str(data['price']))
    })
    
    # Update total
    order['totalAmount'] = sum(
        Decimal(str(item['price'])) * item['quantity']
        for item in order['items']
    )
    
    orders_table.put_item(Item=order)
    
    # Update inventory
    inventory_table.update_item(
        Key={'productId': data['productId']},
        UpdateExpression='ADD reserved :qty',
        ExpressionAttributeValues={':qty': data['quantity']}
    )

def project_order_confirmed(data):
    """Project OrderConfirmed event."""
    orders_table.update_item(
        Key={'orderId': data['orderId']},
        UpdateExpression='SET #status = :status, confirmedAt = :confirmed',
        ExpressionAttributeNames={'#status': 'status'},
        ExpressionAttributeValues={
            ':status': 'confirmed',
            ':confirmed': data['confirmedAt']
        }
    )

def project_order_cancelled(data):
    """Project OrderCancelled event."""
    order_id = data['orderId']
    
    # Get order to release inventory
    response = orders_table.get_item(Key={'orderId': order_id})
    order = response['Item']
    
    # Release inventory
    for item in order['items']:
        inventory_table.update_item(
            Key={'productId': item['productId']},
            UpdateExpression='ADD reserved :qty',
            ExpressionAttributeValues={':qty': -item['quantity']}
        )
    
    # Update order status
    orders_table.update_item(
        Key={'orderId': order_id},
        UpdateExpression='SET #status = :status, cancelledAt = :cancelled',
        ExpressionAttributeNames={'#status': 'status'},
        ExpressionAttributeValues={
            ':status': 'cancelled',
            ':cancelled': data['cancelledAt']
        }
    )
