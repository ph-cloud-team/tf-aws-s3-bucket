# Security

This document describes security controls, compliance considerations, and guardrails for the tf-aws-s3-bucket Terraform module.

## Controls

| Control | Implementation |
| --- | --- |
| Encryption at rest | `aws_s3_bucket_server_side_encryption_configuration` with `aws:kms` |
| KMS rotation | `aws_kms_key.enable_key_rotation = true` by default |
| Public access prevention | `aws_s3_bucket_public_access_block` defaults all controls to `true` |
| Object ownership | `BucketOwnerEnforced` disables ACL-based ownership |
| Versioning | `aws_s3_bucket_versioning` enabled by default |
| Lifecycle | Default multipart cleanup rule plus caller-defined retention rules |
| Access logging | Optional `aws_s3_bucket_logging` targeting a central log bucket |
| Event notifications | EventBridge notifications enabled by default |
| Transport security | Bucket policy denies insecure transport |
| TLS baseline | Bucket policy denies TLS versions below `minimum_tls_version` |
| Required tags | Variable validation requires enterprise tag keys |

## Required Tags

The module requires these caller-provided tags:

- `Environment`
- `Owner`
- `CostCenter`
- `Application`
- `DataClassification`

The module automatically adds:

- `ManagedBy = terraform`
- `Module = tf-aws-s3-bucket`

## Access Logging

Enterprise live repositories should pass a central logging bucket through `access_logging`. The module does not create that central logging bucket because logging buckets are usually account or organization baseline resources.

## Replication

Cross-region replication is intentionally handled by the dedicated `tf-aws-s3-replication` module. Not every enterprise bucket requires replication, and replication needs destination bucket, IAM role, and KMS decisions that are usually workload-classification specific.
