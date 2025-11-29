# Lab Task: Provision a GCE VM with Terraform

## Objective

Your goal is to define and provision a Google Compute Engine VM using Terraform. This introduces the concept of Infrastructure as Code (IaC).

## Requirements

1.  **Terraform Configuration**:
    -   Create a `main.tf` file.
    -   Configure the Google Provider for Terraform. You can set the project and region within the provider block.
    -   Define a `google_compute_instance` resource.

2.  **VM Configuration**:
    -   **Name**: `web-server-tf-01`
    -   **Zone**: `us-central1-a`
    -   **Machine Type**: `e2-micro`
    -   **Image**: Use the latest Debian 11 image. You can use the `google_compute_image` data source to find this dynamically.
    -   **Network Tag**: Assign the `http-server` tag. (You can reuse the firewall rule from the previous lab).
    -   **Startup Script**: Use a startup script to install Apache (`apache2`) and create a custom `index.html` file that says "Hello from a Terraform GCE Instance!".

3.  **Outputs**:
    -   Create a Terraform output to display the external IP address of the VM after it's created.

4.  **Execution**:
    -   Run `terraform init` to initialize the configuration.
    -   Run `terraform plan` to see the execution plan.
    -   Run `terraform apply` to create the resources.
    -   Verify you can access the web server using the IP from the Terraform output.
    -   When you are finished, run `terraform destroy` to clean up the resources.
