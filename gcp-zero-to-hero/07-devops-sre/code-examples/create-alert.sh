#!/bin/bash

# This script shows the gcloud commands to create a notification
# channel and an alerting policy from a JSON file.

# --- Configuration ---
PROJECT_ID=$(gcloud config get-value project)
EMAIL_ADDRESS="your-email@example.com" # Change this
CHANNEL_DISPLAY_NAME="On-Call Email"
POLICY_JSON_FILE="cpu-alert-policy.json"

# --- Execution ---

echo "-------------------------------------------"
echo "1. Creating a notification channel..."
echo "-------------------------------------------"
# This command creates an email notification channel.
# The command will output the full 'name' of the channel,
# which
# you need for the policy definition.
echo "Run this command to create an email channel:"
echo "gcloud alpha monitoring channels create \\"
echo "    --display-name=\""$CHANNEL_DISPLAY_NAME"\" \\"
echo "    --type=\"email\" \\"
echo "    --channel-labels=\"email_address=$EMAIL_ADDRESS\""
echo
echo "After running the command, copy the 'name' field from the output."
echo "Then, paste it into the 'notificationChannels' list in '$POLICY_JSON_FILE'."
echo "Example: 'projects/$PROJECT_ID/notificationChannels/1234567890'"
echo "You will also need to verify the email address by clicking the link sent to you."
echo

# ---

echo "-------------------------------------------"
echo "2. Creating the alerting policy..."
echo "-------------------------------------------"
echo "Once the channel is created and verified, and you have updated the JSON file,"
echo "run this command to create the policy:"
echo "gcloud alpha monitoring policies create --policy-from-file=\""$POLICY_JSON_FILE"\""
echo

# ---

echo "-------------------------------------------"
echo "3. Listing policies to verify..."
echo "-------------------------------------------"
echo "To verify the policy was created, run:"
echo "gcloud alpha monitoring policies list"
echo "-------------------------------------------"

