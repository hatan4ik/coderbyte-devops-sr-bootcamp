# Module 3: GCP Storage and Databases

This module covers GCP's diverse and scalable options for data storage. We will focus on the two most common services: **Cloud Storage** for object storage and **Cloud SQL** for managed relational databases.

## Key Topics

### Cloud Storage
1.  **Buckets**: Creating and configuring storage buckets.
2.  **Storage Classes**: Understanding the difference between Standard, Nearline, Coldline, and Archive.
3.  **Object Versioning & Lifecycle**: Manage object versions and set up rules to automatically transition or delete objects.
4.  **Signed URLs**: Providing temporary, secure access to private objects.
5.  **Static Website Hosting**: Configuring a bucket to host a static website.

### Cloud SQL
1.  **Managed Databases**: Understanding the benefits of a managed database service.
2.  **Instance Creation**: Provisioning a PostgreSQL or MySQL instance.
3.  **High Availability & Replicas**: Configuring for resilience and read scalability.
4.  **Connecting to an Instance**: Using the Cloud SQL Auth Proxy for secure connections.
5.  **Backup and Recovery**: Managing automated backups and performing point-in-time recovery.

## Labs

- **Problem 1**: Create and manage a Cloud Storage bucket, and configure a lifecycle policy using `gsutil`.
- **Problem 2**: Provision a managed PostgreSQL database using Terraform and connect to it.
