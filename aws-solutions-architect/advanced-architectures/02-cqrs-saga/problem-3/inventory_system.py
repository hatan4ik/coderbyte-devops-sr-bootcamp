#!/usr/bin/env python3
"""Inventory management with CQRS pattern."""

import boto3
from decimal import Decimal
from datetime import datetime
import uuid

dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')

event_store = dynamodb.Table('inventory-events')
stock_view = dynamodb.Table('stock-levels')

LOW_STOCK_THRESHOLD = 10

def reserve_stock(product_id: str, warehouse_id: str, quantity: int):
    """Reserve stock for order."""
    
    # Check current stock
    current = get_stock_level(product_id, warehouse_id)
    
    if current < quantity:
        raise ValueError(f'Insufficient stock: {current} < {quantity}')
    
    # Generate event
    event = {
        'eventId': str(uuid.uuid4()),
        'aggregateId': f'{product_id}#{warehouse_id}',
        'version': get_version(product_id, warehouse_id) + 1,
        'eventType': 'StockReserved',
        'productId': product_id,
        'warehouseId': warehouse_id,
        'quantity': quantity,
        'timestamp': datetime.now().isoformat()
    }
    
    event_store.put_item(Item=event)
    
    # Update read model
    new_stock = current - quantity
    stock_view.update_item(
        Key={'productId': product_id, 'warehouseId': warehouse_id},
        UpdateExpression='SET available = available - :qty, reserved = reserved + :qty',
        ExpressionAttributeValues={':qty': quantity}
    )
    
    # Check for low stock alert
    if new_stock <= LOW_STOCK_THRESHOLD:
        send_low_stock_alert(product_id, warehouse_id, new_stock)
    
    return event['eventId']

def release_stock(product_id: str, warehouse_id: str, quantity: int):
    """Release reserved stock."""
    
    event = {
        'eventId': str(uuid.uuid4()),
        'aggregateId': f'{product_id}#{warehouse_id}',
        'version': get_version(product_id, warehouse_id) + 1,
        'eventType': 'StockReleased',
        'productId': product_id,
        'warehouseId': warehouse_id,
        'quantity': quantity,
        'timestamp': datetime.now().isoformat()
    }
    
    event_store.put_item(Item=event)
    
    stock_view.update_item(
        Key={'productId': product_id, 'warehouseId': warehouse_id},
        UpdateExpression='SET available = available + :qty, reserved = reserved - :qty',
        ExpressionAttributeValues={':qty': quantity}
    )
    
    return event['eventId']

def record_sale(product_id: str, warehouse_id: str, quantity: int):
    """Record completed sale."""
    
    event = {
        'eventId': str(uuid.uuid4()),
        'aggregateId': f'{product_id}#{warehouse_id}',
        'version': get_version(product_id, warehouse_id) + 1,
        'eventType': 'SaleRecorded',
        'productId': product_id,
        'warehouseId': warehouse_id,
        'quantity': quantity,
        'timestamp': datetime.now().isoformat()
    }
    
    event_store.put_item(Item=event)
    
    stock_view.update_item(
        Key={'productId': product_id, 'warehouseId': warehouse_id},
        UpdateExpression='SET reserved = reserved - :qty',
        ExpressionAttributeValues={':qty': quantity}
    )
    
    return event['eventId']

def get_stock_level(product_id: str, warehouse_id: str) -> int:
    """Query current stock level."""
    response = stock_view.get_item(
        Key={'productId': product_id, 'warehouseId': warehouse_id}
    )
    
    if 'Item' in response:
        return int(response['Item']['available'])
    return 0

def get_version(product_id: str, warehouse_id: str) -> int:
    """Get current version."""
    response = event_store.query(
        KeyConditionExpression='aggregateId = :id',
        ExpressionAttributeValues={':id': f'{product_id}#{warehouse_id}'},
        ScanIndexForward=False,
        Limit=1
    )
    
    if response['Items']:
        return int(response['Items'][0]['version'])
    return 0

def send_low_stock_alert(product_id: str, warehouse_id: str, quantity: int):
    """Send SNS alert for low stock."""
    sns.publish(
        TopicArn='arn:aws:sns:us-east-1:123456789012:low-stock-alerts',
        Subject='Low Stock Alert',
        Message=f'Product {product_id} in warehouse {warehouse_id} is low: {quantity} units'
    )
