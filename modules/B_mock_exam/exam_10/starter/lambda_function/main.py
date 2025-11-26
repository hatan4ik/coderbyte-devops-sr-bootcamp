import json
import boto3
import os
import logging
from botocore.exceptions import ClientError

# Use environment variables for configuration, not hardcoded strings.
TABLE_NAME = os.environ.get("DYNAMODB_TABLE", "item-tracker")

# Set up structured logging for better observability.
logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):
    logger.info(f"Received event: {json.dumps(event)}")

    http_method = event.get('requestContext', {}).get('http', {}).get('method')
    path = event.get('requestContext', {}).get('http', {}).get('path')

    try:
        if http_method == 'POST' and path == '/items':
            # Security: Validate input to prevent malformed data.
            try:
                body = json.loads(event.get('body', '{}'))
                if 'itemID' not in body:
                    return create_response(400, {'message': 'Validation error: itemID is required.'})
            except json.JSONDecodeError:
                return create_response(400, {'message': 'Invalid JSON in request body.'})

            table.put_item(Item=body)
            return create_response(201, {'message': 'Item created successfully'})

        elif http_method == 'GET' and path.startswith('/items/'):
            path_parts = path.split('/')
            if len(path_parts) < 3 or not path_parts[2]:
                return create_response(400, {'message': 'Invalid path: itemID is missing.'})

            item_id = path_parts[-1]
            response = table.get_item(Key={'itemID': item_id})
            item = response.get('Item')

            if item:
                return create_response(200, item)
            else:
                return create_response(404, {'message': 'Item not found'})
        else:
            return create_response(404, {'message': 'Not Found'})

    # Security & SRE: Catch specific Boto3 errors for more precise responses.
    except ClientError as e:
        error_code = e.response.get("Error", {}).get("Code")
        logger.error(f"Boto3 ClientError: {error_code} - {e}")
        return create_response(500, {'message': f"A database error occurred: {error_code}"})
    except Exception as e:
        logger.error(f"Unhandled exception: {e}", exc_info=True)
        return create_response(500, {'message': 'An unexpected internal server error occurred.'})

def create_response(status_code: int, body: dict) -> dict:
    """
    Creates a standardized HTTP response object for API Gateway.
    """
    return {
        'statusCode': status_code,
        'headers': {
            # Security: Add security headers.
            'Content-Type': 'application/json',
            'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
            'X-Content-Type-Options': 'nosniff',
            'X-Frame-Options': 'DENY',
        },
        'body': json.dumps(body)
    }
