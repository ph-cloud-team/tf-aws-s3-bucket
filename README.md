# tf-aws-s3-bucket

Enterprise Terraform module for creating AWS S3 buckets with secure defaults.

## What This Module Creates

- S3 bucket
- Dedicated KMS key and alias by default
- KMS bucket encryption
- Bucket versioning
- Public access block
- Ownership controls
- Lifecycle configuration
- Optional access logging
- Optional object lock retention
- EventBridge notifications
- Generated bucket policy guardrails

## Enterprise Defaults

- KMS encryption is required.
- KMS key rotation is enabled when the module creates the key.
- Public access is blocked.
- Versioning is enabled.
- ACLs are disabled through `BucketOwnerEnforced`.
- Non-TLS requests are denied.
- TLS versions below `1.2` are denied.
- Incomplete multipart uploads are cleaned up after seven days.
- EventBridge bucket notifications are enabled.
- Required tags are validated.

## Usage

```hcl
module "s3_bucket" {
  source  = "gitlab.midhtech.local/cloud_team/s3-bucket/aws"
  version = "1.0.0"

  bucket_name_prefix = "dev-app-data-"

  access_logging = {
    target_bucket = "central-s3-access-logs"
    target_prefix = "dev/app/"
  }

  tags = {
    Environment        = "dev"
    Owner              = "platform-team"
    CostCenter         = "shared-services"
    Application        = "app"
    DataClassification = "internal"
  }
}
```

## Inputs

| Name | Description | Default |
| --- | --- | --- |
| `bucket_name` | Explicit globally unique bucket name | `null` |
| `bucket_name_prefix` | Prefix for generated bucket name | `null` |
| `create_kms_key` | Create a dedicated KMS key | `true` |
| `kms_key_arn` | Existing KMS key ARN when not creating one | `null` |
| `versioning_enabled` | Enable bucket versioning | `true` |
| `public_access_block` | Public access block settings | all enabled |
| `access_logging` | Central access log bucket configuration | `null` |
| `lifecycle_rules` | Additional lifecycle rules | `[]` |
| `abort_incomplete_multipart_upload_days` | Multipart upload cleanup period | `7` |
| `eventbridge_notifications_enabled` | Enable S3 EventBridge notifications | `true` |
| `bucket_policy_json` | Additional bucket policy JSON | `null` |
| `tags` | Required enterprise tags | required |

## Outputs

| Name | Description |
| --- | --- |
| `bucket_id` | S3 bucket name |
| `bucket_arn` | S3 bucket ARN |
| `bucket_regional_domain_name` | Regional S3 endpoint |
| `kms_key_arn` | KMS key used for bucket encryption |
| `bucket_policy_json` | Rendered bucket policy JSON |

## Validation

```bash
./scripts/validate.sh
```

This module must remain backend-free and provider-free. Live repositories own backend and provider configuration.

## Release

The shared GitLab pipeline publishes this module to the GitLab Terraform Module Registry only when a semantic version tag is pushed.

For this repo, `tf-aws-s3-bucket` is published as:

```text
name: s3-bucket
system: aws
version: <tag without v>
```

Example: pushing tag `v1.0.0` publishes registry version `1.0.0`.

Main branch pipelines validate the module but do not publish a registry version.

## Documentation

- [Architecture](docs/architecture.md)
- [Security](docs/security.md)
- [Usage](docs/usage.md)
- [Code Walkthrough](docs/code-walkthrough.md)
