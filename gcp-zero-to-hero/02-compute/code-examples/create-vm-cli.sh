#!/bin/bash

# This script automates the creation of a GCE VM with a web server,
# as described in the lab task.

# --- Configuration ---
PROJECT_ID="gcp-hero-lab-01" # Change this to your project ID
VM_NAME="web-server-01"
ZONE="us-central1-a"
MACHINE_TYPE="e2-micro"
IMAGE_FAMILY="debian-11"
IMAGE_PROJECT="debian-cloud"
NETWORK_TAG="http-server"
FIREWALL_RULE="allow-http"
STARTUP_SCRIPT_CONTENT='#!/bin/bash
apt-get update
apt-get install -y nginx
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
  <title>Welcome to GCE!</title>
</head>
<body>
  <h1>Hello from my GCE Instance!</h1>
  <p>This page was served by NGINX running on a Google Compute Engine VM.</p>
</body>
</html>
EOF'

# --- Execution ---
echo "Setting project to $PROJECT_ID"
gcloud config set project $PROJECT_ID

echo "Creating firewall rule '$FIREWALL_RULE'"...
gcloud compute firewall-rules create $FIREWALL_RULE \
    --allow tcp:80 \
    --source-ranges "0.0.0.0/0" \
    --target-tags $NETWORK_TAG \
    --description "Allow HTTP inbound traffic"

echo "Creating GCE instance '$VM_NAME'"...
gcloud compute instances create $VM_NAME \
    --zone $ZONE \
    --machine-type $MACHINE_TYPE \
    --image-family $IMAGE_FAMILY \
    --image-project $IMAGE_PROJECT \
    --tags $NETWORK_TAG \
    --metadata "startup-script=$STARTUP_SCRIPT_CONTENT"

echo "--------------------------------------------------"
echo "VM creation initiated. It may take a minute or two for the startup script to complete."
echo "To get the external IP, run:"
echo "gcloud compute instances describe $VM_NAME --zone $ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)'"
echo "Then, open http://<EXTERNAL_IP> in your browser."
echo "--------------------------------------------------"
