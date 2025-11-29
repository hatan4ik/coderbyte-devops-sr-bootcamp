# Module 8: Security

Welcome to Module 8. Security is a fundamental aspect of any cloud environment. This module covers essential GCP security services and concepts, including Identity and Access Management (IAM), service accounts, and network security.

## Learning Objectives

- Understand the principle of least privilege.
- Manage users and permissions with Cloud IAM.
- Create and manage service accounts for application authentication.
- Implement network security using VPC Firewall Rules.
- Secure Cloud Storage buckets.
- Understand the basics of Google's security model.

## Cloud Identity and Access Management (IAM)

**Cloud IAM** lets you grant granular access to specific Google Cloud resources and prevents unwanted access to other resources. IAM lets you adopt the security principle of least privilege, so you grant only the necessary access to your resources.

## Service Accounts

A **service account** is a special type of Google account intended to represent a non-human user such as an application or a virtual machine. Applications use service accounts to make authorized API calls.

## VPC Firewall Rules

**VPC firewall rules** let you allow or deny traffic to and from your virtual machine (VM) instances based on a configuration you specify. Each VPC network functions as a distributed firewall.

## Module Structure

- **Code Examples**: Scripts for managing IAM, service accounts, and a Terraform example for a VPC firewall rule.
- **Problem 1: Secure a Cloud Storage Bucket**: A lab to configure IAM permissions on a storage bucket.
- **Problem 2: Restrict VM Access**: A practical exercise to use firewall rules to control network access to a VM.