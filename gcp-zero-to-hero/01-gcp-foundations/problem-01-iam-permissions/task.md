# Lab Task: Configure Project IAM and Billing

## Objective

Your goal is to configure a new Google Cloud Project with essential security and cost-control measures.

## Requirements

1.  **Create a New Project**:
    -   Create a new GCP project. Name it `gcp-hero-lab-01`.

2.  **Configure Billing Alert**:
    -   Assuming a billing account is attached, create a budget for this project.
    -   Set the budget amount to $50.
    -   Configure the budget to send an alert when 50% and 90% of the budget is consumed.

3.  **Grant IAM Permissions**:
    -   Invite a new user (e.g., `student@example.com`) to the project.
    -   Grant the user the **Compute Viewer** role, allowing them to view Compute Engine resources but not modify them.
    -   Grant the same user the **Storage Object Viewer** role, allowing them to view objects in Cloud Storage buckets but not create or delete them.

4.  **Verification**:
    -   Use the `gcloud` command-line tool or the Cloud Console to verify that the IAM policies and budget are correctly applied to the project.
    -   Write down the `gcloud` commands you would use to verify the IAM roles for the new user.
