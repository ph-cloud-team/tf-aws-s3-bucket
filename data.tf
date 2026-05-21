############################################
# Data sources for tf-aws-s3-bucket
############################################

data "aws_caller_identity" "current" {
  count = var.create_kms_key ? 1 : 0
}

data "aws_partition" "current" {}

data "aws_iam_policy_document" "kms_key" {
  #checkov:skip=CKV_AWS_109:KMS key policies require Resource "*" because the policy is attached to the key and scope is controlled by the key, principal, and service conditions.
  #checkov:skip=CKV_AWS_111:KMS key policies require Resource "*" because the policy is attached to the key and does not grant account-wide IAM permissions.
  #checkov:skip=CKV_AWS_356:KMS key policy Resource "*" is AWS-recommended syntax for key policies and is scoped to this key attachment.
  count = var.create_kms_key ? 1 : 0

  statement {
    sid    = "AllowAccountRootAdministration"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current[0].account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowS3UseOfKey"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:ReEncrypt*"
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "bucket" {
  count = local.bucket_policy_enabled ? 1 : 0

  dynamic "statement" {
    for_each = var.attach_deny_insecure_transport_policy ? [1] : []

    content {
      sid    = "DenyInsecureTransport"
      effect = "Deny"

      principals {
        type        = "*"
        identifiers = ["*"]
      }

      actions = ["s3:*"]

      resources = [
        aws_s3_bucket.this.arn,
        "${aws_s3_bucket.this.arn}/*"
      ]

      condition {
        test     = "Bool"
        variable = "aws:SecureTransport"
        values   = ["false"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.minimum_tls_version == null ? [] : [1]

    content {
      sid    = "DenyOutdatedTLS"
      effect = "Deny"

      principals {
        type        = "*"
        identifiers = ["*"]
      }

      actions = ["s3:*"]

      resources = [
        aws_s3_bucket.this.arn,
        "${aws_s3_bucket.this.arn}/*"
      ]

      condition {
        test     = "NumericLessThan"
        variable = "s3:TlsVersion"
        values   = [var.minimum_tls_version]
      }
    }
  }

  source_policy_documents = var.bucket_policy_json == null ? [] : [var.bucket_policy_json]
}
