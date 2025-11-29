# Module 4: GCP Networking

This module explores the fundamental networking capabilities of GCP, which form the backbone of any cloud deployment. We will focus on the **Virtual Private Cloud (VPC)**, subnets, and firewall rules.

## Key Topics

1.  **VPC Networks**: Understanding the global nature of GCP VPCs and the difference between auto-mode and custom-mode networks.
2.  **Subnets**: Creating subnets within a VPC, defining IP address ranges, and understanding their regional scope.
3.  **Firewall Rules**: Defining ingress and egress rules to control traffic to and from your VM instances. We will cover using network tags to apply rules.
4.  **VPC Network Peering**: Connecting two VPC networks so that they can communicate internally.
5.  **Cloud DNS**: A managed DNS service to host and manage your domain names.
6.  **Cloud Load Balancing**: An overview of different load balancing options available in GCP.

## Labs

- **Problem 1**: Create a custom-mode VPC with two subnets in different regions. Configure firewall rules to allow limited ingress traffic. This lab will be implemented using Terraform.
