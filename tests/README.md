# Tests

This directory is reserved for module validation assets.

## Current Validation

The module currently relies on the shared GitLab module pipeline plus `scripts/validate.sh` for:

- `terraform fmt -check -recursive`
- `terraform init -backend=false`
- `terraform validate`
- example initialization and validation

## Planned Tests

Add fixture-based tests here when policy validation is wired end-to-end:

- `fixtures/valid-s3` for a compliant plan
- `fixtures/missing-logging` for S3 logging policy failure
- `fixtures/missing-versioning` for versioning policy failure
- `fixtures/public-access` for public access block failure
- `fixtures/missing-tags` for common tag policy failure

Negative fixtures should prove that Conftest plan policies fail for non-compliant S3 configurations.

This directory contains unit, integration, and fixture-based tests for the tf-aws-s3-bucket Terraform module.
