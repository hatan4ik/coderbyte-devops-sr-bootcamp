# Lab Task: Create a Custom VPC with Terraform

## Objective

Your task is to define and create a custom-mode Virtual Private Cloud (VPC) with specific subnets and firewall rules using Terraform. This is a foundational skill for building secure and scalable environments in GCP.

## Requirements

1.  **VPC Configuration**:
    -   Create a `google_compute_network` resource for your custom VPC. Name it `my-custom-vpc`.
    -   Ensure `auto_create_subnetworks` is set to `false`.

2.  **Subnet Configuration**:
    -   Create two `google_compute_subnetwork` resources within your VPC:
        1.  **Name**: `subnet-us-central1`
            -   **Region**: `us-central1`
            -   **IP CIDR Range**: `10.10.1.0/24`
        2.  **Name**: `subnet-europe-west1`
            -   **Region**: `europe-west1`
            -   **IP CIDR Range**: `10.20.1.0/24`

3.  **Firewall Rule Configuration**:
    -   Create two `google_compute_firewall` resources associated with your new VPC:
        1.  **Name**: `allow-internal-ssh-icmp`
            -   **Target Tags**: Apply to VMs with the `internal-vm` tag.
            -   **Source Ranges**: Allow traffic only from the IP ranges of your two new subnets (`10.10.1.0/24`, `10.20.1.0/24`).
            -   **Allowed Protocols**: Allow `tcp:22` (SSH) and `icmp`.
        2.  **Name**: `allow-external-health-check`
            -   **Target Tags**: Apply to VMs with the `web-server` tag.
            -   **Source Ranges**: Allow traffic from Google's health checker ranges (`35.191.0.0/16`, `130.211.0.0/22`).
            -   **Allowed Protocols**: Allow `tcp:80`.

4.  **Execution**:
    -   Run `terraform init`, `plan`, and `apply`.
    -   Verify the VPC and firewall rules are created correctly in the GCP Console.
    -   Run `terraform destroy` to clean up.
