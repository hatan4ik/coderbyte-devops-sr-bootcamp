import json
import boto3

secrets_client = boto3.client("secretsmanager")


def lambda_handler(event, context):
    step = event["Step"]
    arn = event["SecretId"]
    token = event["ClientRequestToken"]

    if step == "createSecret":
        _create_secret(arn, token)
    elif step == "setSecret":
        _set_secret(arn, token)
    elif step == "testSecret":
        _test_secret(arn, token)
    elif step == "finishSecret":
        _finish_secret(arn, token)
    else:
        raise ValueError(f"Unknown step {step}")


def _create_secret(arn, token):
    # Generate new credentials here (placeholder).
    username = "appuser"
    password = "REPLACE_ME_GENERATED"
    secret_dict = {"username": username, "password": password}
    secrets_client.put_secret_value(
        SecretId=arn, ClientRequestToken=token, SecretString=json.dumps(secret_dict), VersionStages=["AWSPENDING"]
    )


def _set_secret(arn, token):
    # Apply pending secret to DB (placeholder for DB-specific logic).
    pass


def _test_secret(arn, token):
    # Attempt DB connection with pending secret (placeholder for DB-specific logic).
    pass


def _finish_secret(arn, token):
    secrets_client.update_secret_version_stage(
        SecretId=arn,
        VersionStage="AWSCURRENT",
        MoveToVersionId=token,
        RemoveFromVersionId=_get_current_version(arn),
    )


def _get_current_version(arn):
    meta = secrets_client.describe_secret(SecretId=arn)
    return meta["VersionIdsToStages"].keys().__iter__().__next__()
