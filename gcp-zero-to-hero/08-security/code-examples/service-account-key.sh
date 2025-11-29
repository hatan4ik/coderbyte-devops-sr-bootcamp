#!/bin/bash

SERVICE_ACCOUNT_NAME="my-app-sa"
PROJECT_ID="your-gcp-project-id"

# Create the service account
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
    --display-name="My App Service Account" \
    --project=$PROJECT_ID

SERVICE_ACCOUNT_EMAIL=$(gcloud iam service-accounts list --project=$PROJECT_ID --filter="displayName:'My App Service Account'" --format='value(email)')

# Create a key for the service account
gcloud iam service-accounts keys create ./sa-key.json \
    --iam-account=$SERVICE_ACCOUNT_EMAIL \
    --project=$PROJECT_ID

echo "Service account '$SERVICE_ACCOUNT_NAME' created and key saved to ./sa-key.json"
echo "IMPORTANT: Treat this key file as a secret and do not commit it to version control."
