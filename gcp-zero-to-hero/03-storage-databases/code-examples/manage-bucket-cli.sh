#!/bin/bash

# This script demonstrates the gsutil commands for the Cloud Storage lab.

# --- Configuration ---
# BUCKET_NAME must be globally unique. Using the project ID is a good practice.
PROJECT_ID=$(gcloud config get-value project)
BUCKET_NAME="${PROJECT_ID}-data"
REGION="us-central1"
LIFECYCLE_CONFIG_FILE="lifecycle.json"

# --- Execution ---
echo "Using bucket name: $BUCKET_NAME"

echo "-------------------------------------------"
echo "1. Creating Cloud Storage bucket..."
echo "-------------------------------------------"
gsutil mb -p $PROJECT_ID -c standard -l $REGION gs://$BUCKET_NAME/

echo "-------------------------------------------"
echo "2. Enabling versioning..."
echo "-------------------------------------------"
gsutil versioning set on gs://$BUCKET_NAME

echo "-------------------------------------------"
echo "3. Uploading files to create versions..."
echo "-------------------------------------------"
echo "This is the first version of the file." > sample.txt
gsutil cp sample.txt gs://$BUCKET_NAME/sample.txt
echo "Uploaded v1 of sample.txt"

sleep 2 # Ensure a different timestamp

echo "This is the second and newer version." > sample.txt
gsutil cp sample.txt gs://$BUCKET_NAME/sample.txt
echo "Uploaded v2 of sample.txt"

rm sample.txt
echo "Cleaned up local file."

echo "-------------------------------------------"
echo "4. Listing all versions of the object..."
echo "-------------------------------------------"
gsutil ls -a gs://$BUCKET_NAME/sample.txt

echo "-------------------------------------------"
echo "5. Creating and applying lifecycle policy..."
echo "-------------------------------------------"
# This JSON configuration tells Cloud Storage to delete non-current
# objects if they are more than 30 days old, but always keep the 3 most
# recent non-current versions regardless of age.
cat > $LIFECYCLE_CONFIG_FILE <<EOF
{
  "rule": [
    {
      "action": {
        "type": "Delete"
      },
      "condition": {
        "age": 30,
        "isLive": false,
        "numNewerVersions": 3
      }
    }
  ]
}
EOF
echo "Generated lifecycle.json:"
cat $LIFECYCLE_CONFIG_FILE

gsutil lifecycle set $LIFECYCLE_CONFIG_FILE gs://$BUCKET_NAME
echo "Applied lifecycle policy to the bucket."
rm $LIFECYCLE_CONFIG_FILE

echo "-------------------------------------------"
echo "Verification: Check the bucket in the Cloud Console to see the versions and lifecycle rule."
echo "-------------------------------------------"
