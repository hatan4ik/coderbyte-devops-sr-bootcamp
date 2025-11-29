#!/bin/bash

# This script provides examples of gcloud commands for basic resource verification.

# Set your project ID
PROJECT_ID="gcp-hero-lab-01"
USER_EMAIL="student@example.com"

echo "Setting project to $PROJECT_ID"
gcloud config set project $PROJECT_ID

echo "-------------------------------------------"
echo "Verifying IAM policy for user: $USER_EMAIL"
echo "-------------------------------------------"

# This command lists the project's IAM policy and filters it for the specified user.
# It's a great way to quickly check a user's assigned roles.
gcloud projects get-iam-policy $PROJECT_ID \
  --flatten="bindings[].members" \
  --format='table(bindings.role)' \
  --filter="bindings.members:$USER_EMAIL"

echo "-------------------------------------------"
echo "Listing active budgets for the project"
echo "-------------------------------------------"

# This command lists all budgets associated with the billing account for the project.
# Note: You need appropriate billing permissions to run this.
# The command may vary based on your organization's setup.
gcloud billing budgets list

echo "-------------------------------------------"
echo "Script finished."

