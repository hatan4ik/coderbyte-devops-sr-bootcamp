#!/usr/bin/env python3
"""Account Factory - Automated account provisioning."""

import boto3
import json
from typing import Dict

organizations = boto3.client('organizations')
servicecatalog = boto3.client('servicecatalog')
sts = boto3.client('sts')

def create_account(
    account_name: str,
    email: str,
    ou_name: str,
    tags: Dict[str, str]
) -> str:
    """Create new AWS account via Control Tower."""
    
    # Create account via Organizations
    response = organizations.create_account(
        Email=email,
        AccountName=account_name,
        RoleName='OrganizationAccountAccessRole',
        Tags=[
            {'Key': k, 'Value': v}
            for k, v in tags.items()
        ]
    )
    
    request_id = response['CreateAccountStatus']['Id']
    
    # Wait for account creation
    waiter = organizations.get_waiter('account_created')
    waiter.wait(CreateAccountRequestId=request_id)
    
    # Get account ID
    status = organizations.describe_create_account_status(
        CreateAccountRequestId=request_id
    )
    account_id = status['CreateAccountStatus']['AccountId']
    
    # Move to OU
    move_to_ou(account_id, ou_name)
    
    # Setup baseline
    setup_account_baseline(account_id)
    
    return account_id

def move_to_ou(account_id: str, ou_name: str):
    """Move account to organizational unit."""
    
    # Find OU by name
    root_id = organizations.list_roots()['Roots'][0]['Id']
    
    ous = organizations.list_organizational_units_for_parent(
        ParentId=root_id
    )
    
    ou_id = None
    for ou in ous['OrganizationalUnits']:
        if ou['Name'] == ou_name:
            ou_id = ou['Id']
            break
    
    if not ou_id:
        # Create OU if doesn't exist
        response = organizations.create_organizational_unit(
            ParentId=root_id,
            Name=ou_name
        )
        ou_id = response['OrganizationalUnit']['Id']
    
    # Move account
    organizations.move_account(
        AccountId=account_id,
        SourceParentId=root_id,
        DestinationParentId=ou_id
    )

def setup_account_baseline(account_id: str):
    """Setup baseline configuration for new account."""
    
    # Assume role in new account
    assumed_role = sts.assume_role(
        RoleArn=f'arn:aws:iam::{account_id}:role/OrganizationAccountAccessRole',
        RoleSessionName='AccountSetup'
    )
    
    credentials = assumed_role['Credentials']
    
    # Create session with assumed role
    session = boto3.Session(
        aws_access_key_id=credentials['AccessKeyId'],
        aws_secret_access_key=credentials['SecretAccessKey'],
        aws_session_token=credentials['SessionToken']
    )
    
    # Enable CloudTrail
    enable_cloudtrail(session, account_id)
    
    # Enable Config
    enable_config(session, account_id)
    
    # Enable GuardDuty
    enable_guardduty(session, account_id)
    
    # Setup VPC
    setup_vpc(session)
    
    # Create cross-account roles
    create_cross_account_roles(session, account_id)

def enable_cloudtrail(session, account_id: str):
    """Enable CloudTrail in new account."""
    cloudtrail = session.client('cloudtrail')
    s3 = session.client('s3')
    
    # Create S3 bucket for logs (in log archive account)
    bucket_name = f'cloudtrail-logs-{account_id}'
    
    cloudtrail.create_trail(
        Name='organization-trail',
        S3BucketName=bucket_name,
        IsMultiRegionTrail=True,
        EnableLogFileValidation=True,
        IsOrganizationTrail=False
    )
    
    cloudtrail.start_logging(Name='organization-trail')

def enable_config(session, account_id: str):
    """Enable AWS Config in new account."""
    config = session.client('config')
    
    config.put_configuration_recorder(
        ConfigurationRecorder={
            'name': 'default',
            'roleARN': f'arn:aws:iam::{account_id}:role/aws-service-role/config.amazonaws.com/AWSServiceRoleForConfig',
            'recordingGroup': {
                'allSupported': True,
                'includeGlobalResourceTypes': True
            }
        }
    )
    
    config.put_delivery_channel(
        DeliveryChannel={
            'name': 'default',
            's3BucketName': f'config-logs-{account_id}'
        }
    )
    
    config.start_configuration_recorder(
        ConfigurationRecorderName='default'
    )

def enable_guardduty(session, account_id: str):
    """Enable GuardDuty in new account."""
    guardduty = session.client('guardduty')
    
    response = guardduty.create_detector(
        Enable=True,
        FindingPublishingFrequency='FIFTEEN_MINUTES'
    )
    
    detector_id = response['DetectorId']
    
    # Associate with master account
    guardduty.accept_invitation(
        DetectorId=detector_id,
        MasterId='123456789012',  # Security account
        InvitationId='invitation-id'
    )

def setup_vpc(session):
    """Setup VPC with Transit Gateway attachment."""
    ec2 = session.client('ec2')
    
    # Create VPC
    vpc = ec2.create_vpc(CidrBlock='10.0.0.0/16')
    vpc_id = vpc['Vpc']['VpcId']
    
    # Create subnets
    subnet = ec2.create_subnet(
        VpcId=vpc_id,
        CidrBlock='10.0.1.0/24',
        AvailabilityZone='us-east-1a'
    )
    
    # Attach to Transit Gateway
    ec2.create_transit_gateway_vpc_attachment(
        TransitGatewayId='tgw-123456',
        VpcId=vpc_id,
        SubnetIds=[subnet['Subnet']['SubnetId']]
    )

def create_cross_account_roles(session, account_id: str):
    """Create cross-account IAM roles."""
    iam = session.client('iam')
    
    # Developer role
    iam.create_role(
        RoleName='DeveloperRole',
        AssumeRolePolicyDocument=json.dumps({
            'Version': '2012-10-17',
            'Statement': [{
                'Effect': 'Allow',
                'Principal': {
                    'AWS': 'arn:aws:iam::123456789012:root'
                },
                'Action': 'sts:AssumeRole',
                'Condition': {
                    'StringEquals': {
                        'sts:ExternalId': 'developer-access'
                    }
                }
            }]
        })
    )
    
    iam.attach_role_policy(
        RoleName='DeveloperRole',
        PolicyArn='arn:aws:iam::aws:policy/PowerUserAccess'
    )

# Example usage
if __name__ == '__main__':
    account_id = create_account(
        account_name='Production',
        email='aws-prod@example.com',
        ou_name='Workloads',
        tags={
            'Environment': 'prod',
            'CostCenter': 'engineering',
            'Owner': 'platform-team'
        }
    )
    
    print(f"Created account: {account_id}")
