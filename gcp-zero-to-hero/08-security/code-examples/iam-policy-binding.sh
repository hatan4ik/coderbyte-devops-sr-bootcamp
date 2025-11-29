#!/bin/bash

PROJECT_ID="your-gcp-project-id"
MEMBER_EMAIL="user:example-user@gmail.com" # Can be user:, serviceAccount:, or group: 
ROLE="roles/viewer" # The role to grant

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=$MEMBER_EMAIL \
    --role=$ROLE

echo "Granted role '$ROLE' to '$MEMBER_EMAIL' on project '$PROJECT_ID'."

