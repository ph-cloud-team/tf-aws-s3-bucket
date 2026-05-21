############################################
# Input variables for tf-aws-s3-bucket
############################################

variable "bucket_name" {
  description = "Globally unique S3 bucket name. If null, Terraform creates a unique name from bucket_name_prefix."
  type        = string
  default     = null

  validation {
    condition     = var.bucket_name == null || can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must be a valid S3 bucket name between 3 and 63 characters."
  }
}

variable "bucket_name_prefix" {
  description = "Prefix used to generate a unique bucket name when bucket_name is null."
  type        = string
  default     = null

  validation {
    condition     = var.bucket_name_prefix == null || can(regex("^[a-z0-9][a-z0-9.-]{1,54}$", var.bucket_name_prefix))
    error_message = "bucket_name_prefix must be lowercase, DNS-safe, and short enough for Terraform's generated suffix."
  }
}

variable "force_destroy" {
  description = "Delete all objects when destroying the bucket. Keep false for enterprise workloads."
  type        = bool
  default     = false
}

variable "object_ownership" {
  description = "S3 object ownership mode. BucketOwnerEnforced disables ACLs and is the enterprise default."
  type        = string
  default     = "BucketOwnerEnforced"

  validation {
    condition     = contains(["BucketOwnerEnforced", "BucketOwnerPreferred", "ObjectWriter"], var.object_ownership)
    error_message = "object_ownership must be BucketOwnerEnforced, BucketOwnerPreferred, or ObjectWriter."
  }
}

variable "acl" {
  description = "Optional canned ACL. Leave null when object_ownership is BucketOwnerEnforced."
  type        = string
  default     = null
}

variable "versioning_enabled" {
  description = "Enable S3 bucket versioning."
  type        = bool
  default     = true
}

variable "create_kms_key" {
  description = "Create a dedicated KMS key for S3 default encryption."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "Existing KMS key ARN to use when create_kms_key is false."
  type        = string
  default     = null
}

variable "kms_key_alias" {
  description = "Alias name for the created KMS key. The alias/ prefix is added automatically."
  type        = string
  default     = null
}

variable "kms_key_deletion_window_in_days" {
  description = "Waiting period before AWS KMS deletes the created key."
  type        = number
  default     = 30

  validation {
    condition     = var.kms_key_deletion_window_in_days >= 7 && var.kms_key_deletion_window_in_days <= 30
    error_message = "kms_key_deletion_window_in_days must be between 7 and 30."
  }
}

variable "kms_key_enable_rotation" {
  description = "Enable annual automatic rotation for the created KMS key."
  type        = bool
  default     = true
}

variable "public_access_block" {
  description = "S3 public access block settings. Enterprise default requires every public access block control to remain enabled."
  type = object({
    block_public_acls       = bool
    block_public_policy     = bool
    ignore_public_acls      = bool
    restrict_public_buckets = bool
  })
  default = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }

  validation {
    condition = (
      var.public_access_block.block_public_acls &&
      var.public_access_block.block_public_policy &&
      var.public_access_block.ignore_public_acls &&
      var.public_access_block.restrict_public_buckets
    )
    error_message = "Enterprise S3 buckets must keep all public access block settings enabled."
  }
}

variable "access_logging" {
  description = "Access logging configuration. Enterprise policy should pass a central log bucket."
  type = object({
    target_bucket = string
    target_prefix = optional(string, null)
  })
  default = null
}

variable "lifecycle_rules" {
  description = "Additional S3 lifecycle rules for retention and storage-class transitions. Multipart cleanup is always configured separately."
  type = list(object({
    id                                 = string
    enabled                            = optional(bool, true)
    prefix                             = optional(string, null)
    tags                               = optional(map(string), {})
    expiration_days                    = optional(number, null)
    noncurrent_version_expiration_days = optional(number, null)
    transitions = optional(list(object({
      days          = number
      storage_class = string
    })), [])
    noncurrent_version_transitions = optional(list(object({
      noncurrent_days = number
      storage_class   = string
    })), [])
  }))
  default = []
}

variable "abort_incomplete_multipart_upload_days" {
  description = "Number of days after initiation when incomplete multipart uploads are automatically aborted."
  type        = number
  default     = 7

  validation {
    condition     = var.abort_incomplete_multipart_upload_days >= 1 && var.abort_incomplete_multipart_upload_days <= 7
    error_message = "abort_incomplete_multipart_upload_days must be between 1 and 7."
  }
}

variable "bucket_policy_json" {
  description = "Additional bucket policy JSON merged with generated enterprise guardrails."
  type        = string
  default     = null
}

variable "attach_deny_insecure_transport_policy" {
  description = "Attach a bucket policy statement that denies non-TLS requests."
  type        = bool
  default     = true
}

variable "minimum_tls_version" {
  description = "Minimum TLS version allowed by bucket policy. Set null to skip this guardrail."
  type        = string
  default     = "1.2"

  validation {
    condition     = var.minimum_tls_version == null || contains(["1.2", "1.3"], var.minimum_tls_version)
    error_message = "minimum_tls_version must be null, 1.2, or 1.3."
  }
}

variable "object_lock_enabled" {
  description = "Enable S3 object lock at bucket creation time."
  type        = bool
  default     = false
}

variable "object_lock_configuration" {
  description = "Optional default retention configuration for object lock."
  type = object({
    mode  = string
    days  = optional(number, null)
    years = optional(number, null)
  })
  default = null

  validation {
    condition     = var.object_lock_configuration == null || contains(["GOVERNANCE", "COMPLIANCE"], var.object_lock_configuration.mode)
    error_message = "object_lock_configuration.mode must be GOVERNANCE or COMPLIANCE."
  }
}

variable "eventbridge_notifications_enabled" {
  description = "Enable S3 EventBridge notifications for audit, monitoring, and downstream automation."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Required enterprise tags applied to all supported resources."
  type        = map(string)

  validation {
    condition = alltrue([
      for key in ["Name", "Environment", "Owner", "CostCenter", "Application", "DataClassification"] :
      contains(keys(var.tags), key) && trimspace(var.tags[key]) != ""
    ])
    error_message = "tags must include non-empty Name, Environment, Owner, CostCenter, Application, and DataClassification values."
  }
}
