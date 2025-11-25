import json
import boto3
import os

TABLE_NAME = "item-tracker"
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):
    print(f"Received event: {json.dumps(event)}")
    
    http_method = event.get('requestContext', {}).get('http', {}).get('method')
    path = event.get('requestContext', {}).get('http', {}).get('path')

    try:
        if http_method == 'POST' and path == '/items':
            body = json.loads(event.get('body', '{}'))
            table.put_item(Item=body)
            return {
                'statusCode': 201,
                'body': json.dumps({'message': 'Item created successfully'})
            }

        elif http_method == 'GET' and path.startswith('/items/'):
            path_parts = path.split('/')
            item_id = path_parts[-1]
            response = table.get_item(Key={'itemID': item_id})
            item = response.get('Item')

            if item:
                return {
                    'statusCode': 200,
                    'body': json.dumps(item)
                }
            else:
                return {
                    'statusCode': 404,
                    'body': json.dumps({'message': 'Item not found'})
                }
        else:
            return {
                'statusCode': 400,
                'body': json.dumps({'message': 'Invalid path or method'})
            }
    except Exception as e:
        print(f"Error: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Internal Server Error'})
        }
    finally:
        # Ensure all responses have headers
        if 'headers' not in locals().get('return_value', {}):
            locals().get('return_value', {})['headers'] = {'Content-Type': 'application/json'}