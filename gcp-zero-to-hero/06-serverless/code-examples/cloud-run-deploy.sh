#!/bin/bash

PROJECT_ID="your-gcp-project-id"
REGION="us-central1"
SERVICE_NAME="my-cloud-run-service"
IMAGE="gcr.io/cloud-run/hello" # A sample image provided by Google

gcloud config set project $PROJECT_ID

gcloud run deploy $SERVICE_NAME \
  --image=$IMAGE \
  --platform=managed \
  --region=$REGION \
  --allow-unauthenticated

echo "Service '$SERVICE_NAME' deployed successfully."
echo "You can access it at the URL provided in the output above."
