# Usage

This document describes how to consume the tf-aws-s3-bucket Terraform module from live Terraform repositories.

## Basic

Live repositories consume certified releases from the GitLab Terraform Module Registry.

```hcl
module "s3_bucket" {
  source  = "gitlab.midhtech.local/cloud_team/s3-bucket/aws"
  version = "1.0.0"

  bucket_name_prefix = "dev-app-data-"

  tags = {
    Environment        = "dev"
    Owner              = "platform-team"
    CostCenter         = "shared-services"
    Application        = "example"
    DataClassification = "internal"
  }
}
```

The examples inside this module repo intentionally use `source = "../../"` so the shared module pipeline can validate the current checked-out source before publishing a registry release.

## With Central Access Logging

```hcl
module "s3_bucket" {
  source  = "gitlab.midhtech.local/cloud_team/s3-bucket/aws"
  version = "1.0.0"

  bucket_name_prefix = "dev-app-data-"

  access_logging = {
    target_bucket = "central-s3-access-logs"
    target_prefix = "dev/example/"
  }

  tags = {
    Environment        = "dev"
    Owner              = "platform-team"
    CostCenter         = "shared-services"
    Application        = "example"
    DataClassification = "internal"
  }
}
```

## External KMS Key

```hcl
module "s3_bucket" {
  source  = "gitlab.midhtech.local/cloud_team/s3-bucket/aws"
  version = "1.0.0"

  bucket_name_prefix = "dev-app-data-"
  create_kms_key     = false
  kms_key_arn        = "arn:aws:kms:us-east-1:111122223333:key/example"

  tags = {
    Environment        = "dev"
    Owner              = "platform-team"
    CostCenter         = "shared-services"
    Application        = "example"
    DataClassification = "internal"
  }
}
```
