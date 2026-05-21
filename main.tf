############################################
# Main resources for tf-aws-s3-bucket
############################################

resource "aws_kms_key" "this" {
  count = var.create_kms_key ? 1 : 0

  description             = "KMS key for S3 bucket ${coalesce(var.bucket_name, var.bucket_name_prefix, "generated")}"
  deletion_window_in_days = var.kms_key_deletion_window_in_days
  enable_key_rotation     = var.kms_key_enable_rotation
  policy                  = data.aws_iam_policy_document.kms_key[0].json

  tags = local.common_tags
}

resource "aws_kms_alias" "this" {
  count = var.create_kms_key ? 1 : 0

  name          = "alias/${local.effective_kms_alias}"
  target_key_id = aws_kms_key.this[0].key_id
}

resource "aws_s3_bucket" "this" {
  #checkov:skip=CKV_AWS_144:Cross-region replication is handled by the dedicated tf-aws-s3-replication module when required by workload classification.
  bucket              = var.bucket_name
  bucket_prefix       = var.bucket_name == null ? var.bucket_name_prefix : null
  force_destroy       = var.force_destroy
  object_lock_enabled = var.object_lock_enabled

  tags = local.common_tags

  lifecycle {
    precondition {
      condition     = var.bucket_name != null || var.bucket_name_prefix != null
      error_message = "Set either bucket_name or bucket_name_prefix."
    }

    precondition {
      condition     = !(var.bucket_name != null && var.bucket_name_prefix != null)
      error_message = "Set only one of bucket_name or bucket_name_prefix."
    }

    precondition {
      condition     = var.create_kms_key || var.kms_key_arn != null
      error_message = "kms_key_arn is required when create_kms_key is false."
    }

    precondition {
      condition     = var.object_lock_configuration == null || var.object_lock_enabled
      error_message = "object_lock_enabled must be true when object_lock_configuration is set."
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = var.object_ownership
  }
}

resource "aws_s3_bucket_acl" "this" {
  count = var.acl == null ? 0 : 1

  bucket = aws_s3_bucket.this.id
  acl    = var.acl

  depends_on = [aws_s3_bucket_ownership_controls.this]

  lifecycle {
    precondition {
      condition     = var.object_ownership != "BucketOwnerEnforced"
      error_message = "acl can only be set when object_ownership is not BucketOwnerEnforced."
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.public_access_block.block_public_acls
  block_public_policy     = var.public_access_block.block_public_policy
  ignore_public_acls      = var.public_access_block.ignore_public_acls
  restrict_public_buckets = var.public_access_block.restrict_public_buckets
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = local.bucket_kms_key_arn
      sse_algorithm     = "aws:kms"
    }

    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_logging" "this" {
  count = var.access_logging == null ? 0 : 1

  bucket        = aws_s3_bucket.this.id
  target_bucket = var.access_logging.target_bucket
  target_prefix = coalesce(var.access_logging.target_prefix, "${aws_s3_bucket.this.id}/")
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  #checkov:skip=CKV_AWS_300:Multipart upload cleanup is enforced by the static abort-incomplete-multipart-uploads rule and repeated in dynamic lifecycle rules; Checkov 3.2.525 does not resolve this mixed static/dynamic lifecycle configuration.
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "abort-incomplete-multipart-uploads"
    status = "Enabled"

    filter {
      prefix = ""
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = var.abort_incomplete_multipart_upload_days
    }
  }

  dynamic "rule" {
    for_each = var.lifecycle_rules

    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"

      filter {
        prefix = rule.value.prefix
      }

      dynamic "expiration" {
        for_each = rule.value.expiration_days == null ? [] : [rule.value.expiration_days]

        content {
          days = expiration.value
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration_days == null ? [] : [rule.value.noncurrent_version_expiration_days]

        content {
          noncurrent_days = noncurrent_version_expiration.value
        }
      }

      abort_incomplete_multipart_upload {
        days_after_initiation = var.abort_incomplete_multipart_upload_days
      }

      dynamic "transition" {
        for_each = rule.value.transitions

        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = rule.value.noncurrent_version_transitions

        content {
          noncurrent_days = noncurrent_version_transition.value.noncurrent_days
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }
    }
  }

  depends_on = [aws_s3_bucket_versioning.this]
}

resource "aws_s3_bucket_object_lock_configuration" "this" {
  count = var.object_lock_configuration == null ? 0 : 1

  bucket              = aws_s3_bucket.this.id
  object_lock_enabled = "Enabled"

  rule {
    default_retention {
      mode  = var.object_lock_configuration.mode
      days  = var.object_lock_configuration.days
      years = var.object_lock_configuration.years
    }
  }

  depends_on = [aws_s3_bucket_versioning.this]

  lifecycle {
    precondition {
      condition = (
        var.object_lock_configuration == null ||
        (
          (var.object_lock_configuration.days != null && var.object_lock_configuration.years == null) ||
          (var.object_lock_configuration.days == null && var.object_lock_configuration.years != null)
        )
      )
      error_message = "Set exactly one of object_lock_configuration.days or object_lock_configuration.years."
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  count = local.bucket_policy_enabled ? 1 : 0

  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.bucket[0].json

  depends_on = [aws_s3_bucket_public_access_block.this]
}

resource "aws_s3_bucket_notification" "this" {
  count = var.eventbridge_notifications_enabled ? 1 : 0

  bucket      = aws_s3_bucket.this.id
  eventbridge = true
}
