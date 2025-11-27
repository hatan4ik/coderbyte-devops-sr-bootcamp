#!/usr/bin/env python3
"""Automated security remediation across accounts."""

import boto3
import json

def lambda_handler(event, context):
    """Handle Security Hub findings and auto-remediate."""
    
    detail = event['detail']
    finding_type = detail['findings'][0]['Types'][0]
    account_id = detail['findings'][0]['AwsAccountId']
    resource_id = detail['findings'][0]['Resources'][0]['Id']
    
    # Route to appropriate remediation
    if 'S3' in finding_type and 'Public' in finding_type:
        remediate_public_s3(account_id, resource_id)
    elif 'SecurityGroup' in finding_type:
        remediate_security_group(account_id, resource_id)
    elif 'IAM' in finding_type:
        remediate_iam_issue(account_id, resource_id)
    
    return {'statusCode': 200}

def remediate_public_s3(account_id: str, bucket_arn: str):
    """Block public access on S3 bucket."""
    bucket_name = bucket_arn.split(':')[-1]
    
    # Assume role in member account
    sts = boto3.client('sts')
    assumed = sts.assume_role(
        RoleArn=f'arn:aws:iam::{account_id}:role/SecurityRemediationRole',
        RoleSessionName='SecurityRemediation'
    )
    
    s3 = boto3.client(
        's3',
        aws_access_key_id=assumed['Credentials']['AccessKeyId'],
        aws_secret_access_key=assumed['Credentials']['SecretAccessKey'],
        aws_session_token=assumed['Credentials']['SessionToken']
    )
    
    s3.put_public_access_block(
        Bucket=bucket_name,
        PublicAccessBlockConfiguration={
            'BlockPublicAcls': True,
            'IgnorePublicAcls': True,
            'BlockPublicPolicy': True,
            'RestrictPublicBuckets': True
        }
    )
    
    print(f'Blocked public access on {bucket_name}')

def remediate_security_group(account_id: str, sg_id: str):
    """Remove overly permissive security group rules."""
    sts = boto3.client('sts')
    assumed = sts.assume_role(
        RoleArn=f'arn:aws:iam::{account_id}:role/SecurityRemediationRole',
        RoleSessionName='SecurityRemediation'
    )
    
    ec2 = boto3.client(
        'ec2',
        aws_access_key_id=assumed['Credentials']['AccessKeyId'],
        aws_secret_access_key=assumed['Credentials']['SecretAccessKey'],
        aws_session_token=assumed['Credentials']['SessionToken']
    )
    
    # Get security group rules
    sg = ec2.describe_security_groups(GroupIds=[sg_id])['SecurityGroups'][0]
    
    # Remove 0.0.0.0/0 ingress rules
    for rule in sg['IpPermissions']:
        for ip_range in rule.get('IpRanges', []):
            if ip_range['CidrIp'] == '0.0.0.0/0':
                ec2.revoke_security_group_ingress(
                    GroupId=sg_id,
                    IpPermissions=[rule]
                )
                print(f'Removed open ingress rule from {sg_id}')

def remediate_iam_issue(account_id: str, resource_id: str):
    """Remediate IAM security issues."""
    sts = boto3.client('sts')
    assumed = sts.assume_role(
        RoleArn=f'arn:aws:iam::{account_id}:role/SecurityRemediationRole',
        RoleSessionName='SecurityRemediation'
    )
    
    iam = boto3.client(
        'iam',
        aws_access_key_id=assumed['Credentials']['AccessKeyId'],
        aws_secret_access_key=assumed['Credentials']['SecretAccessKey'],
        aws_session_token=assumed['Credentials']['SessionToken']
    )
    
    # Example: Rotate old access keys
    if 'access-key' in resource_id:
        user_name = resource_id.split('/')[-2]
        access_key_id = resource_id.split('/')[-1]
        
        iam.update_access_key(
            UserName=user_name,
            AccessKeyId=access_key_id,
            Status='Inactive'
        )
        print(f'Deactivated old access key {access_key_id}')
