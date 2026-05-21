# Architecture

This document describes the architecture and design decisions for the tf-aws-s3-bucket Terraform module.

## Resource Model

The module owns one enterprise S3 bucket and the controls directly attached to that bucket:

- `aws_s3_bucket.this` creates the bucket.
- `aws_s3_bucket_public_access_block.this` blocks public exposure.
- `aws_s3_bucket_ownership_controls.this` enforces bucket-owner object ownership.
- `aws_s3_bucket_versioning.this` enables versioning by default.
- `aws_s3_bucket_server_side_encryption_configuration.this` enforces KMS encryption.
- `aws_s3_bucket_lifecycle_configuration.this` manages retention and multipart cleanup.
- `aws_s3_bucket_logging.this` supports central S3 access logging.
- `aws_s3_bucket_notification.this` enables EventBridge notifications.
- `aws_s3_bucket_policy.this` attaches generated and caller-supplied policies.
- `aws_kms_key.this` and `aws_kms_alias.this` create a dedicated encryption key when requested.

## Module Boundaries

This is a reusable Terraform module. It intentionally does not define:

- a Terraform backend
- an AWS provider block
- live-environment state configuration
- account bootstrap resources

Live repositories are responsible for backend configuration, provider configuration, and environment-specific values.

## Defaults

The defaults favor enterprise security:

- KMS encryption is enabled.
- A dedicated KMS key is created by default.
- Public access is fully blocked.
- Versioning is enabled.
- ACLs are disabled through `BucketOwnerEnforced`.
- Non-TLS and old TLS requests are denied by bucket policy.
- Incomplete multipart uploads are cleaned up after seven days.
- EventBridge notifications are enabled by default.
