resource "random_id" "suffix" {
  byte_length = 4
}

# Baseline, compliant state of the demo app's storage bucket.
# During Phase 1 of the demo, the vulnerable block from
# terraform/snippets/vulnerable-bucket.tf.snippet is pasted below this
# resource live in VS Code to trigger the Cortex IDE extension.
resource "aws_s3_bucket" "app_assets" {
  bucket = "cortex-demo-app-assets-${random_id.suffix.hex}"
}

resource "aws_s3_bucket_acl" "app_assets_public" {
  bucket = aws_s3_bucket.app_assets.id
  acl    = "public-read"
}

# Hardcoded credential - flagged by Cortex secrets scanning.
# Uses AWS's own published documentation example key pair (not a real secret).
locals {
  backup_script_credentials = {
    aws_access_key_id     = "AKIAIOSFODNN7EXAMPLE"
    aws_secret_access_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
  }
}

# No aws_s3_bucket_public_access_block resource here: this account's SCP
# denies s3:PutBucketPublicAccessBlock outright (see terraform-bootstrap/
# main.tf). Doesn't affect the Phase 1 demo - the vulnerable-bucket snippet
# is caught by Cortex's static IaC scan on the Terraform code itself, never
# actually applied.
resource "aws_s3_bucket_server_side_encryption_configuration" "app_assets" {
  bucket = aws_s3_bucket.app_assets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "app_assets" {
  bucket = aws_s3_bucket.app_assets.id
  versioning_configuration {
    status = "Enabled"
  }
}
