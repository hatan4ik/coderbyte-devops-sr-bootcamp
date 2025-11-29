# Problem 2: Restrict VM Network Access

## Objective

Your task is to create a Compute Engine VM and use VPC firewall rules and tags to strictly control incoming network traffic to it.

## Scenario

You are deploying a web server on a VM. You need to allow HTTP traffic from anywhere on the internet, but SSH access should be restricted to only your company's IP address range.

## Requirements

1.  **Create a VM**: Create a new Compute Engine VM instance.
    -   You can use a simple `e2-micro` instance.
    -   During creation, add a "network tag" to the VM, for example, `my-web-server`.
2.  **Create a Health Check (Optional but good practice)**: Before creating the firewall rule for HTTP, GCP might require a health check for managed instance groups. For a single VM, we can proceed, but be aware of this for larger setups.
3.  **Create Firewall Rules**:
    -   **Allow HTTP**: Create a firewall rule named `allow-http-on-web-servers` that allows inbound TCP traffic on port `80` from any IP address (`0.0.0.0/0`). This rule should apply *only* to VMs with the `my-web-server` tag.
    -   **Allow SSH**: Create a firewall rule named `allow-ssh-from-corp` that allows inbound TCP traffic on port `22`. This rule should be restricted to a specific source IP range. For this exercise, you can use your own IP address (you can find it by searching "what is my ip" in Google). Append `/32` to your IP to specify a single address (e.g., `203.0.113.5/32`). This rule should also apply only to VMs with the `my-web-server` tag.
4.  **Delete or Disable Default Rules**: For this exercise to be effective, ensure there are no other rules that allow broader access (like a default `allow-ssh` rule with a source of `0.0.0.0/0`). You might need to edit the default rule to be more restrictive or delete it and rely on your new rule. **Be careful not to lock yourself out!**

## Verification

1.  Install a simple web server (like Nginx or Apache) on your VM.
    ```bash
    # For Debian/Ubuntu
    sudo apt-get update
    sudo apt-get install -y nginx
    sudo systemctl start nginx
    ```
2.  From your computer, you should be able to access the web server by navigating to the VM's external IP address in a browser.
3.  From your computer, you should be able to SSH into the VM.
4.  (Challenge) Ask a friend or use a VPN/proxy from a different IP address to try and SSH into the VM. The connection should be blocked by the firewall and time out.

## Using gcloud to create firewall rules

```bash
# HTTP Rule
gcloud compute firewall-rules create allow-http-on-web-servers \
    --network=default \
    --action=ALLOW \
    --direction=INGRESS \
    --rules=tcp:80 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=my-web-server

# SSH Rule
gcloud compute firewall-rules create allow-ssh-from-corp \
    --network=default \
    --action=ALLOW \
    --direction=INGRESS \
    --rules=tcp:22 \
    --source-ranges=YOUR_IP/32 \
    --target-tags=my-web-server
```
