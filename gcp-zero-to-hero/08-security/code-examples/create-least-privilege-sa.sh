#!/bin/bash

# This script demonstrates how to create a service account with least-privilege
# access to a GCS bucket.

# --- Configuration ---
PROJECT_ID=$(gcloud config get-value project)
BUCKET_NAME="${PROJECT_ID}-secure-data"
SA_NAME="storage-reader-sa"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
CUSTOM_ROLE_ID="storageObjectReader"
REGION="us-central1"

# --- Execution ---

echo "-------------------------------------------"
echo "1. Creating GCS bucket..."
echo "-------------------------------------------"
gsutil mb -p $PROJECT_ID -l $REGION gs://$BUCKET_NAME/
echo "Created bucket gs://$BUCKET_NAME"

echo "-------------------------------------------"
echo "2. Creating a custom IAM role..."
echo "-------------------------------------------"
# Check if the role already exists to avoid errors on re-runs
if gcloud iam roles describe $CUSTOM_ROLE_ID --project $PROJECT_ID &>/dev/null; then
  echo "Custom role '$CUSTOM_ROLE_ID' already exists. Skipping creation."
else
  gcloud iam roles create $CUSTOM_ROLE_ID --project $PROJECT_ID \
    --title="Storage Object Reader" \
    --description="Custom role with permissions to read GCS objects" \
    --permissions="storage.objects.get,storage.objects.list" \
    --stage="GA"
  echo "Created custom role '$CUSTOM_ROLE_ID'."
fi


echo "-------------------------------------------"
echo "3. Creating the service account..."
echo "-------------------------------------------"
# Check if the service account already exists
if gcloud iam service-accounts describe $SA_EMAIL &>/dev/null; then
  echo "Service account '$SA_EMAIL' already exists. Skipping creation."
else
  gcloud iam service-accounts create $SA_NAME \
    --display-name="Storage Reader Service Account"
  echo "Created service account '$SA_EMAIL'."
fi


echo "-------------------------------------------"
echo "4. Binding the role to the service account on the bucket..."
echo "-------------------------------------------"
# This is the key step for least privilege. The role is granted only on the bucket.
gsutil iam ch \
  "serviceAccount:${SA_EMAIL}:projects/${PROJECT_ID}/roles/${CUSTOM_ROLE_ID}" \
  gs://$BUCKET_NAME
echo "Granted role '$CUSTOM_ROLE_ID' to '$SA_EMAIL' on bucket 'gs://$BUCKET_NAME'."


echo "-------------------------------------------"
echo "Verification Steps:"
echo "1. Create a test GCE VM and attach the service account:"
echo "   gcloud compute instances create test-vm --zone us-central1-a --machine-type e2-micro --service-account $SA_EMAIL"
echo "2. SSH into the VM:"
echo "   gcloud compute ssh test-vm --zone us-central1-a"
echo "3. From inside the VM, test permissions:"
echo "   echo 'test data' > test.txt"
echo "   gsutil cp test.txt gs://$BUCKET_NAME/test.txt  # This should FAIL"
echo "   gsutil ls gs://$BUCKET_NAME/                  # This should SUCCEED"
echo "-------------------------------------------"
