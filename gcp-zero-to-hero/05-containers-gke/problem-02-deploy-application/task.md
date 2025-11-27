# Problem 2: Deploy an Application to GKE

## Objective

Now that you have a GKE cluster running, your next task is to deploy a containerized web application to it and expose it to the internet.

## Prerequisites

You must have successfully completed "Problem 1: Create a GKE Cluster" and have `kubectl` configured to communicate with your cluster.

## Requirements

1.  **Application**: You will deploy a pre-built sample application from Google's container registry: `gcr.io/google-samples/hello-app:2.0`.

2.  **Deployment**:
    -   Create a Kubernetes `Deployment` for the application.
    -   Name the deployment `hello-app-deployment`.
    -   Configure it to run **3 replicas** of the application container.

3.  **Exposure**:
    -   Create a Kubernetes `Service` to expose the deployment to the internet.
    -   The service should be of type `LoadBalancer`.
    -   It should expose the container's port `8080` to external traffic on port `80`.

## Verification

1.  Apply your deployment and service configurations using `kubectl apply -f <your-config-file.yaml>`.

2.  Check the status of your deployment pods:
    ```bash
    kubectl get pods
    ```
    You should see 3 pods with a `Running` status.

3.  Check the status of your service and find its external IP address:
    ```bash
    kubectl get service hello-app-deployment
    ```
    Wait for the `EXTERNAL-IP` to be assigned. It might take a minute or two.

4.  Once you have the external IP, open your web browser and navigate to `http://<EXTERNAL-IP>`. You should see the "Hello, world!" message from the application, along with the version and the pod name.

## Challenge

Modify the `Deployment` to use version `1.0` of the application (`gcr.io/google-samples/hello-app:1.0`) and apply the change. Observe how Kubernetes performs a rolling update to your application. You can monitor the process with `kubectl get pods`.
