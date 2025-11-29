# Problem 1: Create a GKE Cluster

## Objective

Your task is to create a new Google Kubernetes Engine (GKE) cluster in your GCP project. This will be the foundation for deploying applications in the next problem.

## Requirements

1.  **Cluster Name**: `my-first-gke-cluster`
2.  **Region/Zone**: Use a region and zone of your choice (e.g., `us-central1-c`).
3.  **Node Count**: The cluster should have a default node pool with **2 nodes**.
4.  **Machine Type**: Use the `e2-standard-2` machine type for the nodes.
5.  **Creation Method**: You can use either the `gcloud` command-line tool or Terraform.

## Verification

After creating the cluster, verify its existence and configuration:

1.  If you used `gcloud`, run the following command to see your cluster:
    ```bash
    gcloud container clusters list
    ```

2.  If you used Terraform, ensure the `apply` command completed successfully.

3.  Configure `kubectl` to connect to your new cluster:
    ```bash
    gcloud container clusters get-credentials my-first-gke-cluster --zone <your-chosen-zone>
    ```

4.  Verify that `kubectl` can communicate with the cluster:
    ```bash
    kubectl get nodes
    ```
    This command should show the 2 nodes of your cluster in a `Ready` state.

## Challenge

For an extra challenge, try to create the cluster using the method you are *less* familiar with. If you are comfortable with the CLI, try Terraform, and vice-versa.
