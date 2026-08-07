resource "random_id" "suffix" {
  byte_length = 4
}

# Baseline, compliant state of the demo app's storage bucket.
# During Phase 1 of the demo, the vulnerable block from
# terraform/snippets/vulnerable-bucket.tf.snippet is pasted below this
# resource live in VS Code to trigger the Cortex IDE extension.
resource "aws_s3_bucket" "app_assets" {
  bucket = "cortex-demo-app-assets-${random_id.suffix.hex}"
  tags = {
    Name                 = "cortex-demo-app-assets"
    git_commit           = "4da624fc221b76d601b504aab23984f470a74c6a"
    git_file             = "terraform/main.tf"
    git_last_modified_at = "2026-08-02 13:19:12"
    git_last_modified_by = "agrivet@paloaltonetworks.com"
    git_modifiers        = "agrivet"
    git_org              = "aure-sandbox-pan"
    git_repo             = "cortex-demo-code-to-cloud"
    yor_name             = "app_assets"
    yor_trace            = "05f67201-1d00-4884-aeb0-3b88b295117f"
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
