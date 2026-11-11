# Bucket del estado de Terraform (privado, cifrado y con versiones para recuperar un estado anterior).
resource "aws_s3_bucket" "tfstate" {
  bucket        = "${var.project}-tfstate-${local.account_id}"
  force_destroy = true
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

# Cada cambio del bucket se envia a EventBridge (sin costo mientras no haya reglas que lo usen).
resource "aws_s3_bucket_notification" "tfstate" {
  bucket      = aws_s3_bucket.tfstate.id
  eventbridge = true
}
resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "tfstate_bucket" {
  value = aws_s3_bucket.tfstate.bucket
}
