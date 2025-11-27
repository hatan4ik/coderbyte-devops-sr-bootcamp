terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws" version = "~> 5.0" }
  }
}

provider "aws" {}

variable "artifact_bucket" {
  type        = string
  description = "S3 bucket for pipeline artifacts"
}

locals {
  tags = {
    ManagedBy   = "Terraform"
    Project     = "aws-security-lab-11"
    Environment = "lab"
  }
}

resource "aws_kms_key" "pipeline" {
  description             = "KMS key for pipeline artifacts"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags                    = local.tags
}

resource "aws_s3_bucket" "artifacts" {
  bucket        = var.artifact_bucket
  force_destroy = false
  tags          = merge(local.tags, { Name = var.artifact_bucket })
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.pipeline.arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "codebuild" {
  name               = "pipeline-cb-role"
  assume_role_policy = data.aws_iam_policy_document.cb_assume.json
  tags               = local.tags
}

data "aws_iam_policy_document" "cb_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals { type = "Service" identifiers = ["codebuild.amazonaws.com"] }
  }
}

resource "aws_iam_role_policy" "cb_policy" {
  name = "pipeline-cb-policy"
  role = aws_iam_role.codebuild.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = ["kms:Decrypt", "kms:GenerateDataKey"],
        Resource = aws_kms_key.pipeline.arn
      },
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"],
        Resource = [
          aws_s3_bucket.artifacts.arn,
          "${aws_s3_bucket.artifacts.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_codebuild_project" "scan" {
  name          = "pipeline-scan"
  service_role  = aws_iam_role.codebuild.arn
  build_timeout = 30
  encryption_key = aws_kms_key.pipeline.arn

  artifacts { type = "NO_ARTIFACTS" }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"
    privileged_mode = false
  }

  source {
    type      = "NO_SOURCE"
    buildspec = file("../07-cicd-supply-chain/buildspec.yaml")
  }

  logs_config {
    cloudwatch_logs { status = "ENABLED" }
  }

  tags = local.tags
}

resource "aws_iam_role" "codepipeline" {
  name               = "secure-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.cp_assume.json
  tags               = local.tags
}

data "aws_iam_policy_document" "cp_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals { type = "Service" identifiers = ["codepipeline.amazonaws.com"] }
  }
}

resource "aws_iam_role_policy" "cp_policy" {
  name = "secure-codepipeline-policy"
  role = aws_iam_role.codepipeline.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:GetObject", "s3:GetObjectVersion", "s3:PutObject"],
        Resource = [
          aws_s3_bucket.artifacts.arn,
          "${aws_s3_bucket.artifacts.arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = ["codebuild:BatchGetBuilds", "codebuild:StartBuild"],
        Resource = [aws_codebuild_project.scan.arn]
      },
      {
        Effect = "Allow",
        Action = ["kms:Decrypt", "kms:GenerateDataKey"],
        Resource = aws_kms_key.pipeline.arn
      }
    ]
  })
}

resource "aws_codepipeline" "secure" {
  name     = "secure-pipeline"
  role_arn = aws_iam_role.codepipeline.arn
  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
    encryption_key {
      id   = aws_kms_key.pipeline.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["SourceOutput"]
      configuration = {
        S3Bucket             = aws_s3_bucket.artifacts.bucket
        S3ObjectKey          = "source.zip"
        PollForSourceChanges = "false"
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["SourceOutput"]
      output_artifacts = []
      configuration = {
        ProjectName = aws_codebuild_project.scan.name
      }
    }
  }

  tags = local.tags
}

output "pipeline_name" { value = aws_codepipeline.secure.name }
