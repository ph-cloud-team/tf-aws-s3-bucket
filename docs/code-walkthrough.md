# Code Walkthrough

This document explains the module source files so future reviews can quickly understand why each block exists.

## `variables.tf`

| Lines | Explanation |
| --- | --- |
| 1-3 | File header for module input variables. |
| 5-14 | `bucket_name` lets callers provide an explicit globally unique bucket name and validates the S3 DNS naming pattern. |
| 16-25 | `bucket_name_prefix` lets Terraform generate a unique bucket name from a safe prefix. |
| 27-31 | `force_destroy` controls whether Terraform deletes objects during bucket destroy; default is conservative. |
| 33-42 | `object_ownership` defaults to `BucketOwnerEnforced`, which disables ACL ownership risk. |
| 44-48 | `acl` is optional and should normally stay null because ACLs are disabled by default. |
| 50-54 | `versioning_enabled` keeps versioning on by default for recovery and policy compliance. |
| 56-60 | `create_kms_key` controls whether this module creates a dedicated KMS key. |
| 62-66 | `kms_key_arn` allows use of an existing KMS key when key ownership is centralized. |
| 68-72 | `kms_key_alias` optionally overrides the generated KMS alias name. |
| 74-83 | `kms_key_deletion_window_in_days` sets and validates the KMS deletion waiting period. |
| 85-89 | `kms_key_enable_rotation` enables automatic KMS rotation by default. |
| 91-100 | `public_access_block` exposes S3 public access controls while defaulting all of them to secure values. |
| 102-109 | `access_logging` accepts the central S3 access log bucket and optional prefix. |
| 111-137 | `lifecycle_rules` defines retention, transitions, noncurrent version handling, and multipart cleanup. |
| 139-143 | `bucket_policy_json` allows approved extra policy statements to merge with generated guardrails. |
| 145-149 | `attach_deny_insecure_transport_policy` controls the generated deny statement for HTTP requests. |
| 151-160 | `minimum_tls_version` controls the generated TLS baseline policy and validates allowed values. |
| 162-166 | `object_lock_enabled` turns on object lock at bucket creation time. |
| 168-181 | `object_lock_configuration` optionally configures default governance or compliance retention. |
| 183-194 | `tags` requires enterprise tag keys before the module can plan. |

## `locals.tf`

| Lines | Explanation |
| --- | --- |
| 1-3 | File header for reusable local values. |
| 5 | Starts the `locals` block. |
| 6 | Defines the canonical module name. |
| 7-13 | Merges automatic module tags with caller-provided enterprise tags. |
| 15 | Selects the created KMS key ARN or caller-provided KMS key ARN. |
| 16-20 | Determines whether a bucket policy should be created. |
| 21 | Builds the KMS alias suffix from caller input or bucket naming input. |

## `data.tf`

| Lines | Explanation |
| --- | --- |
| 1-3 | File header for data sources. |
| 5 | Reads the current AWS account ID for the KMS key policy. |
| 7 | Reads the AWS partition so ARNs work in commercial, GovCloud, or China partitions. |
| 9-44 | Builds the KMS key policy when the module creates a key. |
| 12-23 | Allows the account root principal to administer the KMS key. |
| 25-43 | Allows the S3 service to use the KMS key for object encryption operations. |
| 46-104 | Builds the bucket policy when generated guardrails or extra caller policy exist. |
| 49-74 | Optionally creates a deny statement for insecure transport. |
| 76-101 | Optionally creates a deny statement for TLS versions below the configured baseline. |
| 103 | Merges caller-supplied bucket policy JSON into the generated policy document. |

## `main.tf`

| Lines | Explanation |
| --- | --- |
| 1-3 | File header for managed resources. |
| 5-14 | Creates the dedicated KMS key when `create_kms_key` is true. |
| 16-21 | Creates an alias for the module-managed KMS key. |
| 23-52 | Creates the S3 bucket and validates mutually exclusive bucket naming inputs. |
| 31-51 | Adds Terraform preconditions for naming, KMS key requirements, and object lock consistency. |
| 54-60 | Applies object ownership controls. |
| 62-76 | Optionally applies a canned ACL only when ACLs are compatible with object ownership. |
| 78-85 | Blocks public S3 access using AWS public access block settings. |
| 87-93 | Enables or suspends bucket versioning. |
| 95-106 | Enforces default KMS encryption and S3 bucket keys. |
| 108-114 | Optionally enables S3 server access logging to a central bucket. |
| 116-177 | Applies caller-defined lifecycle rules. |
| 121-174 | Expands each lifecycle rule into Terraform nested blocks. |
| 179-207 | Optionally configures object lock default retention. |
| 195-206 | Ensures object lock retention uses exactly one of days or years. |
| 209-216 | Attaches the generated and merged bucket policy. |

## `outputs.tf`

| Output | Explanation |
| --- | --- |
| `module_name` | Returns the canonical module name. |
| `bucket_id` | Returns the S3 bucket name. |
| `bucket_arn` | Returns the S3 bucket ARN. |
| `bucket_domain_name` | Returns the global S3 bucket domain name. |
| `bucket_regional_domain_name` | Returns the regional S3 bucket domain name. |
| `bucket_hosted_zone_id` | Returns the hosted zone ID used for Route 53 aliases. |
| `bucket_region` | Returns the AWS region for the bucket. |
| `kms_key_arn` | Returns the KMS key ARN used for encryption. |
| `kms_key_id` | Returns the created KMS key ID when the module creates a key. |
| `bucket_policy_json` | Returns the rendered bucket policy for audit and debugging. |
