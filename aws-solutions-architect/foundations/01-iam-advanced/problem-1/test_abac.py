#!/usr/bin/env python3
"""Test ABAC implementation with different principal tags."""

import boto3
import json
from typing import Dict, List

def simulate_abac_access(
    role_arn: str,
    principal_tags: Dict[str, str],
    actions: List[str],
    resource_arn: str,
    resource_tags: Dict[str, str]
) -> Dict:
    """Simulate IAM policy evaluation with ABAC."""
    iam = boto3.client('iam')
    
    context_entries = [
        {
            'ContextKeyName': f'aws:PrincipalTag/{key}',
            'ContextKeyValues': [value],
            'ContextKeyType': 'string'
        }
        for key, value in principal_tags.items()
    ]
    
    context_entries.extend([
        {
            'ContextKeyName': f'aws:ResourceTag/{key}',
            'ContextKeyValues': [value],
            'ContextKeyType': 'string'
        }
        for key, value in resource_tags.items()
    ])
    
    response = iam.simulate_principal_policy(
        PolicySourceArn=role_arn,
        ActionNames=actions,
        ResourceArns=[resource_arn],
        ContextEntries=context_entries
    )
    
    return response

def test_project_alpha_dev_access():
    """Test: Developer with Alpha/dev tags can access Alpha/dev resources."""
    role_arn = "arn:aws:iam::123456789012:role/DeveloperABACRole"
    
    result = simulate_abac_access(
        role_arn=role_arn,
        principal_tags={'Project': 'Alpha', 'Environment': 'dev'},
        actions=['s3:GetObject'],
        resource_arn='arn:aws:s3:::project-alpha-dev/*',
        resource_tags={'Project': 'Alpha', 'Environment': 'dev'}
    )
    
    for eval_result in result['EvaluationResults']:
        assert eval_result['EvalDecision'] == 'allowed', \
            f"Expected allowed, got {eval_result['EvalDecision']}"
    
    print("✓ Test passed: Alpha dev can access Alpha dev resources")

def test_cross_project_denied():
    """Test: Developer with Alpha tags cannot access Beta resources."""
    role_arn = "arn:aws:iam::123456789012:role/DeveloperABACRole"
    
    result = simulate_abac_access(
        role_arn=role_arn,
        principal_tags={'Project': 'Alpha', 'Environment': 'dev'},
        actions=['s3:GetObject'],
        resource_arn='arn:aws:s3:::project-beta-dev/*',
        resource_tags={'Project': 'Beta', 'Environment': 'dev'}
    )
    
    for eval_result in result['EvaluationResults']:
        assert eval_result['EvalDecision'] != 'allowed', \
            "Cross-project access should be denied"
    
    print("✓ Test passed: Cross-project access denied")

def test_prod_access_denied():
    """Test: Dev principal cannot access prod resources."""
    role_arn = "arn:aws:iam::123456789012:role/DeveloperABACRole"
    
    result = simulate_abac_access(
        role_arn=role_arn,
        principal_tags={'Project': 'Alpha', 'Environment': 'dev'},
        actions=['s3:GetObject'],
        resource_arn='arn:aws:s3:::project-alpha-prod/*',
        resource_tags={'Project': 'Alpha', 'Environment': 'prod'}
    )
    
    for eval_result in result['EvaluationResults']:
        assert eval_result['EvalDecision'] == 'explicitDeny', \
            "Prod access should be explicitly denied"
    
    print("✓ Test passed: Dev principal cannot access prod")

def query_cloudtrail_abac_events():
    """Query CloudTrail for ABAC access decisions."""
    cloudtrail = boto3.client('cloudtrail')
    
    response = cloudtrail.lookup_events(
        LookupAttributes=[
            {
                'AttributeKey': 'EventName',
                'AttributeValue': 'AssumeRoleWithSAML'
            }
        ],
        MaxResults=50
    )
    
    print("\n=== Recent ABAC AssumeRole Events ===")
    for event in response['Events']:
        event_data = json.loads(event['CloudTrailEvent'])
        if 'requestParameters' in event_data:
            principal_tags = event_data['requestParameters'].get('principalTags', {})
            print(f"Time: {event['EventTime']}")
            print(f"User: {event.get('Username', 'N/A')}")
            print(f"Tags: {principal_tags}")
            print(f"Result: {event_data.get('errorCode', 'Success')}")
            print("-" * 50)

def validate_resource_tagging():
    """Validate all resources have required tags."""
    required_tags = ['Project', 'Environment']
    
    # Check S3 buckets
    s3 = boto3.client('s3')
    buckets = s3.list_buckets()['Buckets']
    
    print("\n=== S3 Bucket Tag Validation ===")
    for bucket in buckets:
        bucket_name = bucket['Name']
        try:
            tags = s3.get_bucket_tagging(Bucket=bucket_name)['TagSet']
            tag_keys = [tag['Key'] for tag in tags]
            
            missing = [tag for tag in required_tags if tag not in tag_keys]
            if missing:
                print(f"✗ {bucket_name}: Missing tags {missing}")
            else:
                print(f"✓ {bucket_name}: All required tags present")
        except s3.exceptions.NoSuchTagSet:
            print(f"✗ {bucket_name}: No tags found")

if __name__ == '__main__':
    print("Testing ABAC Implementation\n")
    
    try:
        test_project_alpha_dev_access()
        test_cross_project_denied()
        test_prod_access_denied()
        query_cloudtrail_abac_events()
        validate_resource_tagging()
        
        print("\n✓ All ABAC tests passed!")
    except Exception as e:
        print(f"\n✗ Test failed: {e}")
        exit(1)
