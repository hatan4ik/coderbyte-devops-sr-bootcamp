# Module 5: Containers & GKE

This module dives into containerization with Docker and orchestration with **Google Kubernetes Engine (GKE)**. GKE is a managed Kubernetes service that simplifies deploying, managing, and scaling containerized applications.

## Key Topics

1.  **GKE Clusters**: Understanding the architecture of a GKE cluster, including the control plane and worker nodes.
2.  **Node Pools**: Creating and managing groups of worker nodes with different machine types.
3.  **Workloads (Deployments & Pods)**: Defining and managing stateless applications using Kubernetes Deployments and Pods.
4.  **Services & Ingress**: Exposing applications to internal or external traffic using Kubernetes Services and Ingress objects.
5.  **Autoscaling**: Configuring horizontal (Pod) and vertical (node) autoscaling.
6.  **`kubectl` CLI**: Using the command-line tool to interact with and manage your GKE cluster and applications.
7.  **GKE Autopilot vs. Standard**: Understanding the differences between the two modes of operation.

## Labs

- **Problem 1**: Provision a standard GKE cluster with a custom node pool using Terraform.
- **Problem 2**: Deploy a pre-built containerized web application to your GKE cluster and expose it to the internet.
