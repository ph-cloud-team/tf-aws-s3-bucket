variable "bucket_name_prefix" {
  description = "Prefix for the generated S3 bucket name."
  type        = string
  default     = "dev-app-data-"
}

variable "access_log_bucket_name" {
  description = "Existing central S3 access log bucket name used by the module plan example."
  type        = string
  default     = "central-s3-access-logs"
}

variable "kms_key_arn" {
  description = "Existing KMS key ARN used by CI plan validation. The shared module pipeline passes this through TF_VAR_kms_key_arn."
  type        = string
}

variable "name" {
  description = "Name tag for the example S3 bucket."
  type        = string
  default     = "dev-example-s3"
}

variable "environment" {
  description = "Deployment environment tag."
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owning team or contact."
  type        = string
  default     = "platform-team"
}

variable "cost_center" {
  description = "Cost center tag."
  type        = string
  default     = "shared-services"
}

variable "application" {
  description = "Application name tag."
  type        = string
  default     = "example"
}

variable "data_classification" {
  description = "Data classification tag."
  type        = string
  default     = "internal"
}
