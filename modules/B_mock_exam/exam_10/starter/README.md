# Serverless Item Tracker Starter

- `lambda_function/main.py`: Lambda handler for POST/GET `/items`.
- `terraform/main.tf`: Provisions DynamoDB table, Lambda, and HTTP API Gateway. Packages code from `../lambda_function` via `archive_file`.
- `../tests/test_api.sh`: Simple smoke test once the API URL is available.

Quick steps:
```bash
cd terraform
terraform init
terraform apply
# export API_URL from terraform output
cd ../tests
./test_api.sh "$API_URL"
```
