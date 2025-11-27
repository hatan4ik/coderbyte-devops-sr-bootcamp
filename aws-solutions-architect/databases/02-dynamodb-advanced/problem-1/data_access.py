#!/usr/bin/env python3
"""DynamoDB Single-Table Data Access Layer."""

import boto3
from boto3.dynamodb.conditions import Key, Attr
from datetime import datetime, timedelta
from decimal import Decimal
from typing import Dict, List, Optional
import uuid

class SaaSDataAccess:
    """Data access layer for multi-tenant SaaS platform."""
    
    def __init__(self, table_name: str):
        self.dynamodb = boto3.resource('dynamodb')
        self.table = self.dynamodb.Table(table_name)
    
    # Access Pattern 1: Get user by email
    def get_user_by_email(self, email: str) -> Optional[Dict]:
        """Query GSI1 with email as partition key."""
        response = self.table.query(
            IndexName='GSI1',
            KeyConditionExpression=Key('GSI1PK').eq(f'USER#{email}')
        )
        return response['Items'][0] if response['Items'] else None
    
    # Access Pattern 2: Get all users in organization
    def get_org_users(self, org_id: str) -> List[Dict]:
        """Query main table with org PK and USER SK prefix."""
        response = self.table.query(
            KeyConditionExpression=Key('PK').eq(f'ORG#{org_id}') & 
                                   Key('SK').begins_with('USER#')
        )
        return response['Items']
    
    # Access Pattern 3: Get user's orders sorted by date
    def get_user_orders(self, user_id: str, limit: int = 50) -> List[Dict]:
        """Query GSI1 with user as PK and order timestamp as SK."""
        response = self.table.query(
            IndexName='GSI1',
            KeyConditionExpression=Key('GSI1PK').eq(f'USER#{user_id}') &
                                   Key('GSI1SK').begins_with('ORDER#'),
            ScanIndexForward=False,  # Descending order
            Limit=limit
        )
        return response['Items']
    
    # Access Pattern 4: Get organization revenue (aggregated)
    def get_org_revenue(self, org_id: str, days: int = 30) -> Decimal:
        """Query orders and aggregate revenue."""
        cutoff = datetime.now() - timedelta(days=days)
        cutoff_str = cutoff.isoformat()
        
        response = self.table.query(
            KeyConditionExpression=Key('PK').eq(f'ORG#{org_id}') &
                                   Key('SK').begins_with('ORDER#'),
            FilterExpression=Attr('timestamp').gte(cutoff_str)
        )
        
        total = sum(Decimal(str(item.get('amount', 0))) for item in response['Items'])
        return total
    
    # Access Pattern 5: Get product inventory across warehouses
    def get_product_inventory(self, product_id: str) -> List[Dict]:
        """Query GSI2 for product across all warehouses."""
        response = self.table.query(
            IndexName='GSI2',
            KeyConditionExpression=Key('GSI2PK').eq(f'PRODUCT#{product_id}')
        )
        return response['Items']
    
    # Access Pattern 6: Get invoice by ID
    def get_invoice(self, org_id: str, invoice_id: str) -> Optional[Dict]:
        """Direct get with composite key."""
        response = self.table.get_item(
            Key={
                'PK': f'ORG#{org_id}',
                'SK': f'INVOICE#{invoice_id}'
            }
        )
        return response.get('Item')
    
    # Access Pattern 7: List invoices for organization (paginated)
    def list_org_invoices(
        self, 
        org_id: str, 
        status: Optional[str] = None,
        limit: int = 20,
        last_key: Optional[Dict] = None
    ) -> Dict:
        """Query invoices with optional status filter."""
        kwargs = {
            'KeyConditionExpression': Key('PK').eq(f'ORG#{org_id}') &
                                     Key('SK').begins_with('INVOICE#'),
            'Limit': limit
        }
        
        if status:
            kwargs['FilterExpression'] = Attr('status').eq(status)
        
        if last_key:
            kwargs['ExclusiveStartKey'] = last_key
        
        response = self.table.query(**kwargs)
        
        return {
            'items': response['Items'],
            'last_key': response.get('LastEvaluatedKey')
        }
    
    # Access Pattern 8: Get top customers by spend
    def get_top_customers(self, org_id: str, limit: int = 10) -> List[Dict]:
        """Query and aggregate customer spend."""
        response = self.table.query(
            KeyConditionExpression=Key('PK').eq(f'ORG#{org_id}') &
                                   Key('SK').begins_with('ORDER#')
        )
        
        # Aggregate by customer
        customer_spend = {}
        for order in response['Items']:
            customer_id = order.get('customer_id')
            amount = Decimal(str(order.get('amount', 0)))
            customer_spend[customer_id] = customer_spend.get(customer_id, Decimal(0)) + amount
        
        # Sort and return top N
        top_customers = sorted(
            customer_spend.items(),
            key=lambda x: x[1],
            reverse=True
        )[:limit]
        
        return [
            {'customer_id': cid, 'total_spend': float(spend)}
            for cid, spend in top_customers
        ]
    
    # Write Operations
    def create_user(self, org_id: str, email: str, name: str) -> str:
        """Create new user with proper keys."""
        user_id = str(uuid.uuid4())
        timestamp = datetime.now().isoformat()
        
        self.table.put_item(
            Item={
                'PK': f'ORG#{org_id}',
                'SK': f'USER#{user_id}',
                'GSI1PK': f'USER#{email}',
                'GSI1SK': f'ORG#{org_id}',
                'user_id': user_id,
                'email': email,
                'name': name,
                'created_at': timestamp,
                'entity_type': 'USER'
            }
        )
        return user_id
    
    def create_order(
        self, 
        org_id: str, 
        user_id: str, 
        amount: float,
        items: List[Dict]
    ) -> str:
        """Create new order."""
        order_id = str(uuid.uuid4())
        timestamp = datetime.now().isoformat()
        
        self.table.put_item(
            Item={
                'PK': f'ORG#{org_id}',
                'SK': f'ORDER#{order_id}',
                'GSI1PK': f'USER#{user_id}',
                'GSI1SK': f'ORDER#{timestamp}',
                'order_id': order_id,
                'user_id': user_id,
                'amount': Decimal(str(amount)),
                'items': items,
                'timestamp': timestamp,
                'status': 'pending',
                'entity_type': 'ORDER'
            }
        )
        return order_id
    
    def create_invoice(
        self,
        org_id: str,
        order_id: str,
        amount: float,
        due_date: str
    ) -> str:
        """Create invoice with TTL."""
        invoice_id = str(uuid.uuid4())
        timestamp = datetime.now().isoformat()
        
        # TTL: 1 year from now
        ttl = int((datetime.now() + timedelta(days=365)).timestamp())
        
        self.table.put_item(
            Item={
                'PK': f'ORG#{org_id}',
                'SK': f'INVOICE#{invoice_id}',
                'GSI2PK': f'STATUS#pending',
                'GSI2SK': f'INVOICE#{timestamp}',
                'invoice_id': invoice_id,
                'order_id': order_id,
                'amount': Decimal(str(amount)),
                'due_date': due_date,
                'status': 'pending',
                'created_at': timestamp,
                'TTL': ttl,
                'entity_type': 'INVOICE'
            }
        )
        return invoice_id
    
    def update_invoice_status(self, org_id: str, invoice_id: str, status: str):
        """Update invoice status (moves GSI2 partition)."""
        timestamp = datetime.now().isoformat()
        
        self.table.update_item(
            Key={
                'PK': f'ORG#{org_id}',
                'SK': f'INVOICE#{invoice_id}'
            },
            UpdateExpression='SET #status = :status, GSI2PK = :gsi2pk, updated_at = :updated',
            ExpressionAttributeNames={
                '#status': 'status'
            },
            ExpressionAttributeValues={
                ':status': status,
                ':gsi2pk': f'STATUS#{status}',
                ':updated': timestamp
            }
        )
    
    # Batch Operations
    def batch_get_items(self, keys: List[Dict]) -> List[Dict]:
        """Batch get multiple items."""
        response = self.dynamodb.batch_get_item(
            RequestItems={
                self.table.name: {
                    'Keys': keys
                }
            }
        )
        return response['Responses'][self.table.name]
    
    def batch_write_items(self, items: List[Dict]):
        """Batch write multiple items."""
        with self.table.batch_writer() as batch:
            for item in items:
                batch.put_item(Item=item)

# Example Usage
if __name__ == '__main__':
    dao = SaaSDataAccess('saas-platform-prod')
    
    # Create organization and users
    org_id = 'org-123'
    user_id = dao.create_user(org_id, 'john@example.com', 'John Doe')
    
    # Create order
    order_id = dao.create_order(
        org_id=org_id,
        user_id=user_id,
        amount=99.99,
        items=[{'product_id': 'prod-1', 'quantity': 2}]
    )
    
    # Query patterns
    user = dao.get_user_by_email('john@example.com')
    print(f"User: {user}")
    
    orders = dao.get_user_orders(user_id)
    print(f"Orders: {len(orders)}")
    
    revenue = dao.get_org_revenue(org_id, days=30)
    print(f"30-day revenue: ${revenue}")
    
    top_customers = dao.get_top_customers(org_id, limit=5)
    print(f"Top customers: {top_customers}")
