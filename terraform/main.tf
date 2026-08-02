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

resource "aws_s3_bucket_public_access_block" "app_assets" {
  bucket                  = aws_s3_bucket.app_assets.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

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
