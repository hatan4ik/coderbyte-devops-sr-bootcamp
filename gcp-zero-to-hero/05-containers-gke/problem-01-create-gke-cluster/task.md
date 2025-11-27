# Lab Task: Provision a GKE Cluster with Terraform

## Objective

Your task is to provision a standard GKE (Google Kubernetes Engine) cluster using Terraform, configured with a specific node pool for running workloads.

## Requirements

1.  **Terraform Configuration**:
    -   Set up your `main.tf` file to use the Google Provider.
    -   Define a `google_container_cluster` resource for the GKE cluster itself (the control plane).
    -   Define a `google_container_node_pool` resource for the worker nodes.

2.  **GKE Cluster (Control Plane) Configuration**:
    -   **Name**: `primary-gke-cluster`
    -   **Location**: `us-central1` (use a zonal cluster for this lab, so pick `us-central1-a`).
    -   **Initial Node Count**: `1`. We are creating a separate node pool, so the initial default pool can be minimal.
    -   **Deletion Protection**: `false`.

3.  **GKE Node Pool Configuration**:
    -   **Name**: `general-purpose-pool`
    -   **Location**: `us-central1-a`
    -   **Cluster**: Associate it with the cluster you defined above.
    -   **Node Count**: `2`
    -   **Machine Type**: `e2-medium`
    -   **OAuth Scopes**: Ensure the nodes have the necessary scopes to access other GCP services, like `cloud-platform`.

4.  **Outputs**:
    -   Output the GKE cluster `name`.
    -   Output the GKE cluster `endpoint` (the IP address of the control plane).

5.  **Execution**:
    -   Run `terraform init`, `plan`, and `apply`.
    -   Verify the cluster and node pool are created in the GCP Console.
    -   (Optional) Configure `kubectl` to connect to your new cluster. You can get the command by running `gcloud container clusters get-credentials primary-gke-cluster --zone us-central1-a`.
    -   Run `terraform destroy` when you are finished.
