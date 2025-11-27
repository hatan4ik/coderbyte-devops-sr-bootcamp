#!/usr/bin/env python3
"""Banking command handlers with event sourcing."""

import boto3
import json
from datetime import datetime
from decimal import Decimal
import uuid

dynamodb = boto3.resource('dynamodb')
event_store = dynamodb.Table('banking-events')
snapshots = dynamodb.Table('account-snapshots')

def handle_deposit(account_id: str, amount: Decimal, idempotency_key: str):
    """Handle deposit command."""
    
    # Check idempotency
    if is_duplicate(idempotency_key):
        return {'status': 'duplicate'}
    
    # Load current state
    state = load_account_state(account_id)
    
    if state['status'] == 'closed':
        raise ValueError('Account is closed')
    
    # Generate event
    event = {
        'eventId': str(uuid.uuid4()),
        'accountId': account_id,
        'version': state['version'] + 1,
        'eventType': 'MoneyDeposited',
        'amount': amount,
        'timestamp': datetime.now().isoformat(),
        'idempotencyKey': idempotency_key
    }
    
    # Store event with optimistic lock
    try:
        event_store.put_item(
            Item=event,
            ConditionExpression='attribute_not_exists(accountId) AND attribute_not_exists(version)'
        )
    except dynamodb.meta.client.exceptions.ConditionalCheckFailedException:
        raise ValueError('Concurrency conflict')
    
    # Check if snapshot needed
    if event['version'] % 100 == 0:
        create_snapshot(account_id, state['version'])
    
    return {'eventId': event['eventId'], 'version': event['version']}

def handle_withdraw(account_id: str, amount: Decimal, idempotency_key: str):
    """Handle withdrawal command."""
    
    if is_duplicate(idempotency_key):
        return {'status': 'duplicate'}
    
    state = load_account_state(account_id)
    
    if state['balance'] < amount:
        raise ValueError('Insufficient funds')
    
    event = {
        'eventId': str(uuid.uuid4()),
        'accountId': account_id,
        'version': state['version'] + 1,
        'eventType': 'MoneyWithdrawn',
        'amount': amount,
        'timestamp': datetime.now().isoformat(),
        'idempotencyKey': idempotency_key
    }
    
    try:
        event_store.put_item(
            Item=event,
            ConditionExpression='attribute_not_exists(accountId) AND attribute_not_exists(version)'
        )
    except dynamodb.meta.client.exceptions.ConditionalCheckFailedException:
        raise ValueError('Concurrency conflict')
    
    return {'eventId': event['eventId'], 'version': event['version']}

def handle_transfer(from_account: str, to_account: str, amount: Decimal, idempotency_key: str):
    """Handle transfer between accounts."""
    
    if is_duplicate(idempotency_key):
        return {'status': 'duplicate'}
    
    # Withdraw from source
    withdraw_event = {
        'eventId': str(uuid.uuid4()),
        'accountId': from_account,
        'version': load_account_state(from_account)['version'] + 1,
        'eventType': 'MoneyWithdrawn',
        'amount': amount,
        'transferTo': to_account,
        'timestamp': datetime.now().isoformat(),
        'idempotencyKey': f"{idempotency_key}-withdraw"
    }
    
    # Deposit to destination
    deposit_event = {
        'eventId': str(uuid.uuid4()),
        'accountId': to_account,
        'version': load_account_state(to_account)['version'] + 1,
        'eventType': 'MoneyDeposited',
        'amount': amount,
        'transferFrom': from_account,
        'timestamp': datetime.now().isoformat(),
        'idempotencyKey': f"{idempotency_key}-deposit"
    }
    
    # Store both events atomically
    event_store.put_item(Item=withdraw_event)
    event_store.put_item(Item=deposit_event)
    
    return {'transferId': idempotency_key}

def load_account_state(account_id: str):
    """Load account state from snapshot + events."""
    
    # Try to load latest snapshot
    snapshot_response = snapshots.query(
        KeyConditionExpression='accountId = :id',
        ExpressionAttributeValues={':id': account_id},
        ScanIndexForward=False,
        Limit=1
    )
    
    if snapshot_response['Items']:
        snapshot = snapshot_response['Items'][0]
        state = {
            'accountId': account_id,
            'balance': Decimal(str(snapshot['balance'])),
            'version': int(snapshot['version']),
            'status': snapshot['status']
        }
        from_version = state['version'] + 1
    else:
        state = {
            'accountId': account_id,
            'balance': Decimal('0'),
            'version': 0,
            'status': 'active'
        }
        from_version = 1
    
    # Apply events since snapshot
    events_response = event_store.query(
        KeyConditionExpression='accountId = :id AND version >= :v',
        ExpressionAttributeValues={':id': account_id, ':v': from_version}
    )
    
    for event in events_response['Items']:
        apply_event(state, event)
    
    return state

def apply_event(state, event):
    """Apply event to state."""
    event_type = event['eventType']
    
    if event_type == 'AccountOpened':
        state['status'] = 'active'
    elif event_type == 'MoneyDeposited':
        state['balance'] += Decimal(str(event['amount']))
    elif event_type == 'MoneyWithdrawn':
        state['balance'] -= Decimal(str(event['amount']))
    elif event_type == 'AccountClosed':
        state['status'] = 'closed'
    
    state['version'] = int(event['version'])

def create_snapshot(account_id: str, version: int):
    """Create snapshot for performance."""
    state = load_account_state(account_id)
    
    snapshots.put_item(
        Item={
            'accountId': account_id,
            'version': version,
            'balance': float(state['balance']),
            'status': state['status'],
            'timestamp': datetime.now().isoformat()
        }
    )

def is_duplicate(idempotency_key: str) -> bool:
    """Check if command already processed."""
    response = event_store.scan(
        FilterExpression='idempotencyKey = :key',
        ExpressionAttributeValues={':key': idempotency_key},
        Limit=1
    )
    return len(response['Items']) > 0
