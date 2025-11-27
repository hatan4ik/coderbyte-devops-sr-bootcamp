#!/usr/bin/env python3
"""FAANG-grade CQRS command handler with type safety and functional patterns."""

from __future__ import annotations
from dataclasses import dataclass, field, asdict
from typing import Protocol, TypeVar, Generic, Callable, Optional, Union, List
from enum import Enum
from datetime import datetime
from decimal import Decimal
import uuid
import boto3
from functools import wraps
import structlog
from aws_xray_sdk.core import xray_recorder
from botocore.exceptions import ClientError

# Structured logging
logger = structlog.get_logger()

# Type variables
T = TypeVar('T')
E = TypeVar('E', bound='Event')
C = TypeVar('C', bound='Command')

# Domain types
class OrderStatus(Enum):
    DRAFT = "draft"
    CONFIRMED = "confirmed"
    CANCELLED = "cancelled"
    SHIPPED = "shipped"

class EventType(Enum):
    ORDER_CREATED = "OrderCreated"
    ITEM_ADDED = "ItemAdded"
    ITEM_REMOVED = "ItemRemoved"
    DISCOUNT_APPLIED = "DiscountApplied"
    ORDER_CONFIRMED = "OrderConfirmed"
    ORDER_CANCELLED = "OrderCancelled"

# Result type for functional error handling
@dataclass(frozen=True)
class Result(Generic[T]):
    """Functional Result type for error handling without exceptions."""
    value: Optional[T] = None
    error: Optional[str] = None
    
    @property
    def is_success(self) -> bool:
        return self.error is None
    
    @property
    def is_failure(self) -> bool:
        return self.error is not None
    
    def map(self, fn: Callable[[T], T]) -> Result[T]:
        """Functor map operation."""
        return Result(fn(self.value), None) if self.is_success else self
    
    def flat_map(self, fn: Callable[[T], Result[T]]) -> Result[T]:
        """Monad bind operation."""
        return fn(self.value) if self.is_success else self
    
    def get_or_else(self, default: T) -> T:
        """Get value or return default."""
        return self.value if self.is_success else default
    
    def get_or_raise(self) -> T:
        """Get value or raise exception."""
        if self.is_failure:
            raise ValueError(self.error)
        return self.value

    @staticmethod
    def success(value: T) -> Result[T]:
        return Result(value=value)
    
    @staticmethod
    def failure(error: str) -> Result[T]:
        return Result(error=error)

# Event Protocol
class Event(Protocol):
    """Event interface for type safety."""
    event_id: str
    aggregate_id: str
    version: int
    event_type: EventType
    timestamp: str
    
    def to_dict(self) -> dict: ...

# Command Protocol
class Command(Protocol):
    """Command interface for type safety."""
    aggregate_id: str
    idempotency_key: str
    
    def validate(self) -> Result[bool]: ...

# Domain Events
@dataclass(frozen=True)
class OrderCreated:
    event_id: str
    aggregate_id: str
    version: int
    event_type: EventType = EventType.ORDER_CREATED
    customer_id: str = ""
    timestamp: str = field(default_factory=lambda: datetime.utcnow().isoformat())
    
    def to_dict(self) -> dict:
        return {**asdict(self), 'event_type': self.event_type.value}

@dataclass(frozen=True)
class ItemAdded:
    event_id: str
    aggregate_id: str
    version: int
    event_type: EventType = EventType.ITEM_ADDED
    product_id: str = ""
    quantity: int = 0
    price: Decimal = Decimal('0')
    timestamp: str = field(default_factory=lambda: datetime.utcnow().isoformat())
    
    def to_dict(self) -> dict:
        d = asdict(self)
        d['event_type'] = self.event_type.value
        d['price'] = float(self.price)
        return d

@dataclass(frozen=True)
class OrderConfirmed:
    event_id: str
    aggregate_id: str
    version: int
    event_type: EventType = EventType.ORDER_CONFIRMED
    timestamp: str = field(default_factory=lambda: datetime.utcnow().isoformat())
    
    def to_dict(self) -> dict:
        return {**asdict(self), 'event_type': self.event_type.value}

# Aggregate State
@dataclass
class OrderAggregate:
    """Immutable aggregate state rebuilt from events."""
    order_id: str
    customer_id: str
    status: OrderStatus
    items: List[dict]
    total: Decimal
    version: int
    
    @staticmethod
    def empty(order_id: str) -> OrderAggregate:
        return OrderAggregate(
            order_id=order_id,
            customer_id="",
            status=OrderStatus.DRAFT,
            items=[],
            total=Decimal('0'),
            version=0
        )
    
    def apply(self, event: Event) -> OrderAggregate:
        """Pure function to apply event to state."""
        if isinstance(event, OrderCreated):
            return OrderAggregate(
                order_id=self.order_id,
                customer_id=event.customer_id,
                status=OrderStatus.DRAFT,
                items=self.items,
                total=self.total,
                version=event.version
            )
        elif isinstance(event, ItemAdded):
            new_items = self.items + [{
                'product_id': event.product_id,
                'quantity': event.quantity,
                'price': event.price
            }]
            new_total = self.total + (event.price * event.quantity)
            return OrderAggregate(
                order_id=self.order_id,
                customer_id=self.customer_id,
                status=self.status,
                items=new_items,
                total=new_total,
                version=event.version
            )
        elif isinstance(event, OrderConfirmed):
            return OrderAggregate(
                order_id=self.order_id,
                customer_id=self.customer_id,
                status=OrderStatus.CONFIRMED,
                items=self.items,
                total=self.total,
                version=event.version
            )
        return self

# Repository with functional interface
class EventStore:
    """Event store with functional error handling."""
    
    def __init__(self, table_name: str):
        self.dynamodb = boto3.resource('dynamodb')
        self.table = self.dynamodb.Table(table_name)
        self.logger = logger.bind(component="EventStore")
    
    @xray_recorder.capture('append_event')
    def append(self, event: Event) -> Result[Event]:
        """Append event with optimistic concurrency control."""
        try:
            self.table.put_item(
                Item=event.to_dict(),
                ConditionExpression='attribute_not_exists(aggregate_id) AND attribute_not_exists(version)'
            )
            self.logger.info("event_appended", 
                           event_id=event.event_id,
                           aggregate_id=event.aggregate_id,
                           version=event.version)
            return Result.success(event)
        except ClientError as e:
            if e.response['Error']['Code'] == 'ConditionalCheckFailedException':
                return Result.failure("ConcurrencyConflict")
            return Result.failure(f"DynamoDBError: {str(e)}")
    
    @xray_recorder.capture('load_events')
    def load(self, aggregate_id: str) -> Result[List[Event]]:
        """Load all events for aggregate."""
        try:
            response = self.table.query(
                KeyConditionExpression='aggregate_id = :id',
                ExpressionAttributeValues={':id': aggregate_id},
                ScanIndexForward=True
            )
            events = [self._deserialize_event(item) for item in response['Items']]
            return Result.success(events)
        except ClientError as e:
            return Result.failure(f"LoadError: {str(e)}")
    
    def _deserialize_event(self, item: dict) -> Event:
        """Deserialize DynamoDB item to Event."""
        event_type = EventType(item['event_type'])
        
        if event_type == EventType.ORDER_CREATED:
            return OrderCreated(**item)
        elif event_type == EventType.ITEM_ADDED:
            item['price'] = Decimal(str(item['price']))
            return ItemAdded(**item)
        elif event_type == EventType.ORDER_CONFIRMED:
            return OrderConfirmed(**item)
        
        raise ValueError(f"Unknown event type: {event_type}")

# Command Handler with functional composition
class CommandHandler:
    """FAANG-grade command handler with functional patterns."""
    
    def __init__(self, event_store: EventStore):
        self.event_store = event_store
        self.logger = logger.bind(component="CommandHandler")
    
    def handle(self, command: C, handler_fn: Callable[[C, OrderAggregate], Result[Event]]) -> Result[Event]:
        """Generic command handling with functional composition."""
        return (
            self._load_aggregate(command.aggregate_id)
            .flat_map(lambda agg: handler_fn(command, agg))
            .flat_map(self.event_store.append)
        )
    
    def _load_aggregate(self, aggregate_id: str) -> Result[OrderAggregate]:
        """Load and rebuild aggregate from events."""
        return (
            self.event_store.load(aggregate_id)
            .map(lambda events: self._rebuild_aggregate(aggregate_id, events))
        )
    
    def _rebuild_aggregate(self, aggregate_id: str, events: List[Event]) -> OrderAggregate:
        """Fold events into aggregate state."""
        initial = OrderAggregate.empty(aggregate_id)
        return self._fold_left(initial, events, lambda agg, evt: agg.apply(evt))
    
    @staticmethod
    def _fold_left(initial: T, items: List, fn: Callable[[T, any], T]) -> T:
        """Functional fold/reduce operation."""
        result = initial
        for item in items:
            result = fn(result, item)
        return result

# Command Handlers
@dataclass(frozen=True)
class CreateOrderCommand:
    aggregate_id: str
    customer_id: str
    idempotency_key: str
    
    def validate(self) -> Result[bool]:
        if not self.customer_id:
            return Result.failure("CustomerIdRequired")
        return Result.success(True)

@dataclass(frozen=True)
class AddItemCommand:
    aggregate_id: str
    product_id: str
    quantity: int
    price: Decimal
    idempotency_key: str
    
    def validate(self) -> Result[bool]:
        if self.quantity <= 0:
            return Result.failure("InvalidQuantity")
        if self.price <= 0:
            return Result.failure("InvalidPrice")
        return Result.success(True)

@dataclass(frozen=True)
class ConfirmOrderCommand:
    aggregate_id: str
    idempotency_key: str
    
    def validate(self) -> Result[bool]:
        return Result.success(True)

# Business Logic Handlers
def handle_create_order(cmd: CreateOrderCommand, agg: OrderAggregate) -> Result[Event]:
    """Handle CreateOrder command with business rules."""
    if agg.version > 0:
        return Result.failure("OrderAlreadyExists")
    
    event = OrderCreated(
        event_id=str(uuid.uuid4()),
        aggregate_id=cmd.aggregate_id,
        version=1,
        customer_id=cmd.customer_id
    )
    return Result.success(event)

def handle_add_item(cmd: AddItemCommand, agg: OrderAggregate) -> Result[Event]:
    """Handle AddItem command with business rules."""
    if agg.status != OrderStatus.DRAFT:
        return Result.failure("OrderNotInDraftState")
    
    event = ItemAdded(
        event_id=str(uuid.uuid4()),
        aggregate_id=cmd.aggregate_id,
        version=agg.version + 1,
        product_id=cmd.product_id,
        quantity=cmd.quantity,
        price=cmd.price
    )
    return Result.success(event)

def handle_confirm_order(cmd: ConfirmOrderCommand, agg: OrderAggregate) -> Result[Event]:
    """Handle ConfirmOrder command with business rules."""
    if agg.status != OrderStatus.DRAFT:
        return Result.failure("OrderNotInDraftState")
    
    if not agg.items:
        return Result.failure("OrderHasNoItems")
    
    event = OrderConfirmed(
        event_id=str(uuid.uuid4()),
        aggregate_id=cmd.aggregate_id,
        version=agg.version + 1
    )
    return Result.success(event)

# Lambda Handler with dependency injection
def create_handler(event_store: EventStore, command_handler: CommandHandler):
    """Factory function for Lambda handler with DI."""
    
    @xray_recorder.capture('lambda_handler')
    def handler(event: dict, context) -> dict:
        """Lambda handler with functional error handling."""
        try:
            command_type = event['pathParameters']['command']
            body = event['body']
            
            result = (
                _parse_command(command_type, body)
                .flat_map(lambda cmd: cmd.validate().map(lambda _: cmd))
                .flat_map(lambda cmd: _execute_command(cmd, command_handler))
            )
            
            if result.is_success:
                return {
                    'statusCode': 200,
                    'body': {'event_id': result.value.event_id, 'version': result.value.version}
                }
            else:
                logger.error("command_failed", error=result.error)
                return {
                    'statusCode': 400 if 'Conflict' not in result.error else 409,
                    'body': {'error': result.error}
                }
        except Exception as e:
            logger.exception("unexpected_error")
            return {'statusCode': 500, 'body': {'error': 'InternalServerError'}}
    
    return handler

def _parse_command(command_type: str, body: dict) -> Result[Command]:
    """Parse command from request."""
    try:
        if command_type == 'CreateOrder':
            return Result.success(CreateOrderCommand(**body))
        elif command_type == 'AddItem':
            body['price'] = Decimal(str(body['price']))
            return Result.success(AddItemCommand(**body))
        elif command_type == 'ConfirmOrder':
            return Result.success(ConfirmOrderCommand(**body))
        return Result.failure("UnknownCommandType")
    except Exception as e:
        return Result.failure(f"ParseError: {str(e)}")

def _execute_command(cmd: Command, handler: CommandHandler) -> Result[Event]:
    """Execute command with appropriate handler."""
    if isinstance(cmd, CreateOrderCommand):
        return handler.handle(cmd, handle_create_order)
    elif isinstance(cmd, AddItemCommand):
        return handler.handle(cmd, handle_add_item)
    elif isinstance(cmd, ConfirmOrderCommand):
        return handler.handle(cmd, handle_confirm_order)
    return Result.failure("NoHandlerFound")

# Bootstrap
event_store = EventStore('event-store')
command_handler = CommandHandler(event_store)
lambda_handler = create_handler(event_store, command_handler)
