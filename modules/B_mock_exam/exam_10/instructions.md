# Mock Exam #10: Serverless Architecture

**Challenge:** Deploy a serverless "Item Tracker" API using AWS Lambda, API Gateway, and DynamoDB. All infrastructure must be provisioned with Terraform.

## Requirements

### 1. Infrastructure (Terraform)
- Provision a **DynamoDB table** named `item-tracker` with a primary key `itemID` (String).
- Provision an **IAM Role** for the Lambda function that grants it permissions to read/write to the DynamoDB table and write logs to CloudWatch.
- Provision a **Python 3.9 Lambda function**. The code for this function will be in the `starter/lambda_function` directory. You will need to package it as a `.zip` file for deployment.
- Provision an **API Gateway (HTTP API)** that triggers the Lambda function.
- The API must expose two endpoints:
  - `POST /items`: Creates a new item in the DynamoDB table.
  - `GET /items/{itemID}`: Retrieves an item by its ID from the DynamoDB table.
- Output the invoke URL of the API Gateway.

### 2. Application Logic (Python Lambda)
- The Lambda function must handle both `POST` and `GET` requests from the API Gateway.
- **For `POST /items`**: The request body will be a JSON object (e.g., `{"itemID": "item123", "data": "some value"}`). The function must write this item to the DynamoDB table.
- **For `GET /items/{itemID}`**: The function must retrieve the item with the specified `itemID` from the DynamoDB table and return it in the response body.

### 3. Validation
- Use the script in the `tests/` directory to validate that your API is working correctly.

## Getting Started

All the files you need to start are in the `starter/` directory. Good luck!