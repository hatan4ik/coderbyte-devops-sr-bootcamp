# Lab Task: Deploy an Application to GKE

## Objective

Deploy a pre-built containerized application to your GKE cluster and expose it to the internet using a Kubernetes Service. This lab requires you to have a running GKE cluster and `kubectl` configured to connect to it.

## Requirements

1.  **Create a Kubernetes Manifest File**:
    -   Create a file named `web-app.yaml`.
    -   This file should contain two resource definitions: a `Deployment` and a `Service`.

2.  **Deployment Configuration**:
    -   **Name**: `hello-web`
    -   **Replicas**: `3`. The Deployment should manage 3 Pods.
    -   **Container Image**: Use `us-docker.pkg.dev/google-samples/containers/gke/hello-app:1.0`. This is a public sample image provided by Google.
    -   **Container Port**: The application in the container listens on port `8080`.

3.  **Service Configuration**:
    -   **Name**: `hello-web-service`
    -   **Type**: `LoadBalancer`. This will provision a Google Cloud Load Balancer to expose the service externally.
    -   **Selector**: The Service must select the Pods managed by your `hello-web` Deployment.
    -   **Ports**: The Service should listen on port `80` and forward traffic to the container's target port `8080`.

4.  **Execution**:
    -   Use `kubectl apply -f web-app.yaml` to deploy your application.
    -   Run `kubectl get pods` to check that your 3 pods are running.
    -   Run `kubectl get service hello-web-service` and wait for it to be assigned an `EXTERNAL-IP`.
    -   Verify you can access the application by navigating to the external IP in your browser.

5.  **Cleanup**:
    -   Run `kubectl delete -f web-app.yaml` to remove the application from your cluster.
