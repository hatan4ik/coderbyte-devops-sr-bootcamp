# Module 8: GCP Security

This module focuses on securing GCP resources and implementing security best practices. We will cover identity and access management, service account security, and network security at the edge.

## Key Topics

1.  **Identity and Access Management (IAM) Best Practices**:
    -   **Principle of Least Privilege**: Granting only the permissions required to perform a task.
    -   **Custom Roles**: Creating fine-grained roles to avoid using overly permissive primitive roles.
    -   **IAM Conditions**: Granting permissions that are only active under specific conditions (e.g., time of day, resource name).

2.  **Service Accounts**:
    -   Understanding the role of service accounts for application authentication.
    -   Creating and managing service account keys (and why to avoid them).
    -   Attaching service accounts to resources like GCE VMs.

3.  **Network Security**:
    -   **Cloud Armor**: A network security service that helps you defend your applications from Distributed Denial-of-Service (DDoS) attacks and other web-based threats. We will cover IP blocklists and preconfigured WAF rules.
    -   **Identity-Aware Proxy (IAP)**: A service that uses identity and context to guard access to your applications and VMs.

4.  **Security Command Center**: An overview of GCP's centralized security and risk management platform.

## Labs

- **Problem 1**: Create a least-privilege service account for an application that needs to read from Cloud Storage but not write.
- **Problem 2**: Configure a Cloud Armor security policy to block a specific IP address from accessing a load-balanced web service.
