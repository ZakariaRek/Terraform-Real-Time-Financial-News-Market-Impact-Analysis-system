# modules/s3/main.tf
# S3 Bucket Module for Market Impact Analysis System

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# KMS Key for S3 bucket encryption
resource "aws_kms_key" "s3" {
  description             = "KMS key for S3 bucket ${var.bucket_name} encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-s3-kms-key"
    }
  )
}

resource "aws_kms_alias" "s3" {
  name          = "alias/${var.environment}-s3-${var.bucket_purpose}"
  target_key_id = aws_kms_key.s3.key_id
}

# S3 Bucket
resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name

  tags = merge(
    var.common_tags,
    {
      Name    = var.bucket_name
      Purpose = var.bucket_purpose
    }
  )
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

# S3 Bucket Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
    bucket_key_enabled = true
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Lifecycle Configuration
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  count  = var.lifecycle_rules_enabled ? 1 : 0
  bucket = aws_s3_bucket.main.id

  # Transition to Intelligent-Tiering after 30 days
  rule {
    id     = "intelligent-tiering"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "INTELLIGENT_TIERING"
    }
  }

  # Archive old versions to Glacier after 90 days
  rule {
    id     = "archive-old-versions"
    status = "Enabled"

    noncurrent_version_transition {
      noncurrent_days = 90
      storage_class   = "GLACIER"
    }
  }

  # Delete old versions after 365 days
  rule {
    id     = "delete-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 365
    }
  }

  # Abort incomplete multipart uploads after 7 days
  rule {
    id     = "abort-incomplete-uploads"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# S3 Bucket Logging
resource "aws_s3_bucket_logging" "main" {
  count  = var.logging_enabled ? 1 : 0
  bucket = aws_s3_bucket.main.id

  target_bucket = var.logging_bucket != null ? var.logging_bucket : aws_s3_bucket.main.id
  target_prefix = "logs/${var.bucket_name}/"
}

# S3 Bucket Policy for EKS access
resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSSLRequestsOnly"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.main.arn,
          "${aws_s3_bucket.main.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Sid    = "AllowEKSNodeAccess"
        Effect = "Allow"
        Principal = {
          AWS = var.eks_node_role_arn != null ? [var.eks_node_role_arn] : []
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.main.arn,
          "${aws_s3_bucket.main.arn}/*"
        ]
      }
    ]
  })
}

# S3 Bucket CORS Configuration (if needed for web access)
resource "aws_s3_bucket_cors_configuration" "main" {
  count  = var.cors_enabled ? 1 : 0
  bucket = aws_s3_bucket.main.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    allowed_origins = var.cors_allowed_origins
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# S3 Bucket Notification (for event-driven processing)
resource "aws_s3_bucket_notification" "main" {
  count  = var.notifications_enabled ? 1 : 0
  bucket = aws_s3_bucket.main.id

  dynamic "topic" {
    for_each = var.notification_topic_arn != null ? [1] : []
    content {
      topic_arn = var.notification_topic_arn
      events    = ["s3:ObjectCreated:*"]
    }
  }
}

# CloudWatch Metric Alarm for S3 bucket size
resource "aws_cloudwatch_metric_alarm" "bucket_size" {
  count               = var.size_monitoring_enabled ? 1 : 0
  alarm_name          = "${var.environment}-${var.bucket_name}-size"
  alarm_description   = "S3 bucket ${var.bucket_name} size monitoring"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "BucketSizeBytes"
  namespace           = "AWS/S3"
  period              = "86400"  # 1 day
  statistic           = "Average"
  threshold           = var.size_threshold_bytes

  dimensions = {
    BucketName  = aws_s3_bucket.main.id
    StorageType = "StandardStorage"
  }

  alarm_actions = var.alarm_actions
  ok_actions    = var.alarm_actions

  tags = var.common_tags
}