# Lab Task: Create a Custom GCE VM with a Startup Script

## Objective

Your task is to create a Google Compute Engine VM, install a web server on it using a startup script, and configure it to be accessible from the internet.

## Requirements

1.  **VM Configuration**:
    -   **Name**: `web-server-01`
    -   **Zone**: `us-central1-a`
    -   **Machine Type**: `e2-micro` (to minimize cost)
    -   **Image**: Use a recent Debian 11 image (e.g., `debian-11-bullseye-v20230101` from the `debian-cloud` project).

2.  **Networking**:
    -   The VM should be accessible from the internet. Assign a network tag to the VM, for example, `http-server`.
    -   Create a **firewall rule** named `allow-http` that allows TCP traffic on port `80` for all sources (`0.0.0.0/0`). This rule should target VMs with the `http-server` tag.

3.  **Startup Script**:
    -   Provide a startup script that does the following:
        -   Updates the package manager (`apt-get update`).
        -   Installs `nginx`.
        -   Creates a custom `index.html` file in `/var/www/html` that displays "Hello from my GCE Instance!".

4.  **Verification**:
    -   Once the VM is running, find its external IP address.
    -   Verify that you can access the web server from your browser or by using `curl` on the external IP.
    -   Provide the full `gcloud` command you used to create the VM and the firewall rule.
