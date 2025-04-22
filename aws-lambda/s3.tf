resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
  numeric = false
}

resource "aws_s3_bucket" "project_static" {
  # bucket names are global and must be unique across all aws accounts. Consider adding a random suffix when name
  bucket = "${var.project}-${var.env}-web-${random_string.suffix.id}"
  provisioner "local-exec" {
    command = "aws s3 cp --recursive ../app/static/ s3://${self.bucket}/static/"
  }
}

# Properties
resource "aws_s3_bucket_versioning" "project_static" {
  bucket = aws_s3_bucket.project_static.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "project_static" {
  bucket = aws_s3_bucket.project_static.id

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Permissions
resource "aws_s3_bucket_public_access_block" "project_static" {
  bucket = aws_s3_bucket.project_static.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "project_static" {
  bucket = aws_s3_bucket.project_static.id
  policy = data.aws_iam_policy_document.s3_project_static_bucket_policy.json
}

resource "aws_s3_bucket_ownership_controls" "project_static" {
  bucket = aws_s3_bucket.project_static.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
