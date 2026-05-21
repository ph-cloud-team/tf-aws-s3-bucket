variable "bucket_name_prefix" {
  description = "Prefix for the generated S3 bucket name."
  type        = string
  default     = "dev-enterprise-data-"
}

variable "access_log_bucket_name" {
  description = "Existing central S3 access log bucket name."
  type        = string
}

variable "name" {
  description = "Name tag for the example S3 bucket."
  type        = string
  default     = "dev-enterprise-s3"
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
  default     = "enterprise-example"
}

variable "data_classification" {
  description = "Data classification tag."
  type        = string
  default     = "internal"
}
