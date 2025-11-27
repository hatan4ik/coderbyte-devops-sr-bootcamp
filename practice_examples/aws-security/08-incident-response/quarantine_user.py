#!/usr/bin/env python3
import sys
import boto3
from botocore.exceptions import ClientError

DENY_POLICY_NAME = "QuarantineDenyAll"
DENY_POLICY_DOC = {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Deny",
            "Action": "*",
            "Resource": "*"
        }
    ]
}

def quarantine_user(username: str):
    iam = boto3.client("iam")

    # Detach managed policies
    attached = iam.list_attached_user_policies(UserName=username)["AttachedPolicies"]
    for pol in attached:
        print(f"Detaching policy {pol['PolicyArn']} from {username}")
        iam.detach_user_policy(UserName=username, PolicyArn=pol["PolicyArn"])

    # Deactivate access keys
    keys = iam.list_access_keys(UserName=username)["AccessKeyMetadata"]
    for key in keys:
        print(f"Deactivating access key {key['AccessKeyId']} for {username}")
        iam.update_access_key(UserName=username, AccessKeyId=key["AccessKeyId"], Status="Inactive")

    # Put deny-all inline policy
    print(f"Attaching deny-all inline policy to {username}")
    iam.put_user_policy(UserName=username, PolicyName=DENY_POLICY_NAME, PolicyDocument=json_dump(DENY_POLICY_DOC))


def json_dump(obj):
    import json
    return json.dumps(obj)


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <username>", file=sys.stderr)
        sys.exit(1)
    username = sys.argv[1]
    try:
        quarantine_user(username)
    except ClientError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
