#!/bin/bash

# Set your project ID and desired zone
PROJECT_ID="your-gcp-project-id"
ZONE="us-central1-c"
CLUSTER_NAME="my-gke-cluster"

# Authenticate with gcloud
gcloud auth login
gcloud config set project $PROJECT_ID
gcloud config set compute/zone $ZONE

# Enable necessary APIs
gcloud services enable container.googleapis.com

# Create a GKE cluster
gcloud container clusters create $CLUSTER_NAME \
  --num-nodes=2 \
  --machine-type=e2-medium \
  --zone=$ZONE

echo "GKE cluster '$CLUSTER_NAME' created successfully."

# Get cluster credentials
gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE

echo "kubectl is now configured to use the '$CLUSTER_NAME' cluster."
