# One-time, manual bootstrap: creates the S3 bucket that holds the remote
# state for terraform/. Apply this once from a local terminal with your own
# AWS credentials - it is never run by GitHub Actions. Everything in
# terraform/ (the actual demo infra) is applied by .github/workflows/cd.yml.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "tfstate" {
  bucket = "cortex-demo-tfstate-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# No aws_s3_bucket_public_access_block resource here: this account's SCP
# (p-iusphgmf) explicitly denies s3:PutBucketPublicAccessBlock outright, on
# any bucket/value. S3 buckets are private by default with no public bucket
# policy or ACL set (neither of which this config sets), so the omission
# doesn't change actual exposure - it's a compliance-tooling gap, not a
# security one, for this account.

output "tfstate_bucket" {
  value = aws_s3_bucket.tfstate.bucket
}
