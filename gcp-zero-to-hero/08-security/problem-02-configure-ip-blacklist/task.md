# Lab Task: Configure a Cloud Armor IP Blacklist

## Objective

Your task is to create and apply a Google Cloud Armor security policy that denies access to a web application from a specific IP address, simulating a blacklist.

## Prerequisites

-   A working HTTP Load Balancer. This typically involves:
    -   A GCE instance group with a simple web server running.
    -   A Backend Service.
    -   A URL Map and Target Proxy.
    -   A Forwarding Rule with an external IP address.
    *You can set this up manually or using Terraform, but it must be in place before starting the lab.*

## Requirements

1.  **Create a Cloud Armor Security Policy**:
    -   Create a new security policy named `ip-blacklist-policy`.
    -   The policy should have a default rule that allows all traffic. This is the standard last rule in a policy.

2.  **Add a Deny Rule**:
    -   Add a new rule to the policy with a higher priority than the default rule (e.g., priority `1000`).
    -   The rule should have the action `deny (403)`.
    -   The rule should match traffic from a specific IP address or range. For this lab, you can use a test IP like `192.0.2.1/32`.
    -   Give the rule a description, e.g., "Block test IP".

3.  **Attach Policy to Backend Service**:
    -   Attach the `ip-blacklist-policy` to the Backend Service that your HTTP Load Balancer uses.

4.  **Verification**:
    -   Verify that you can access the web application from your own IP address.
    -   Use `curl` or a similar tool to simulate a request from the blocked IP address. You can do this by adding a header to your request (note: this only simulates the IP, a true test requires a machine with that IP). A more practical approach is to temporarily add your *own* IP to the blocklist, verify you are blocked, and then remove it.
        -   Run `curl -I http://<LOAD_BALANCER_IP>`. You should get a `200 OK`.
        -   Add your IP to the blacklist rule.
        -   Run `curl -I http://<LOAD_BALANCER_IP>` again. You should now get a `403 Forbidden`.
    -   Provide the Terraform or `gcloud` commands used to create and apply the policy.
