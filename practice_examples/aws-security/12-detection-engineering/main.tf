terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws" version = "~> 5.0" }
  }
}

provider "aws" {}

locals {
  tags = {
    ManagedBy   = "Terraform"
    Project     = "aws-security-lab-12"
    Environment = "lab"
  }
}

resource "aws_sns_topic" "alerts" {
  name = "security-alerts"
  tags = local.tags
}

resource "aws_cloudwatch_event_rule" "root_login" {
  name        = "detect-root-login"
  description = "Alert on root ConsoleLogin"
  event_pattern = jsonencode({
    "detail-type": ["AWS Console Sign In via CloudTrail"],
    "detail": {
      "userIdentity": { "type": ["Root"] },
      "eventName": ["ConsoleLogin"],
      "responseElements": {"ConsoleLogin": ["Success", "Failure"]}
    }
  })
}

resource "aws_cloudwatch_event_target" "root_login_target" {
  rule      = aws_cloudwatch_event_rule.root_login.name
  target_id = "send-to-sns"
  arn       = aws_sns_topic.alerts.arn
}

resource "aws_cloudwatch_event_rule" "iam_changes" {
  name        = "detect-iam-changes"
  description = "Alert on IAM changes"
  event_pattern = jsonencode({
    "source": ["aws.iam"],
    "detail-type": ["AWS API Call via CloudTrail"],
    "detail": {
      "eventSource": ["iam.amazonaws.com"],
      "eventName": [
        "CreateUser", "UpdateUser", "DeleteUser",
        "CreateRole", "UpdateRole", "DeleteRole",
        "PutUserPolicy", "PutRolePolicy", "DeleteUserPolicy", "DeleteRolePolicy",
        "CreateAccessKey", "DeleteAccessKey", "UpdateAccessKey"
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "iam_changes_target" {
  rule      = aws_cloudwatch_event_rule.iam_changes.name
  target_id = "send-to-sns"
  arn       = aws_sns_topic.alerts.arn
}

# Permissions for EventBridge to publish to SNS
resource "aws_sns_topic_policy" "allow_events" {
  arn    = aws_sns_topic.alerts.arn
  policy = data.aws_iam_policy_document.events_to_sns.json
}

data "aws_iam_policy_document" "events_to_sns" {
  statement {
    effect = "Allow"
    principals { type = "Service" identifiers = ["events.amazonaws.com"] }
    actions   = ["SNS:Publish"]
    resources = [aws_sns_topic.alerts.arn]
  }
}

output "sns_topic_arn" { value = aws_sns_topic.alerts.arn }
output "event_rules" { value = [aws_cloudwatch_event_rule.root_login.name, aws_cloudwatch_event_rule.iam_changes.name] }
