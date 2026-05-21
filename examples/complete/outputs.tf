output "bucket_id" {
  description = "Name of the created S3 bucket."
  value       = module.tf_aws_s3_bucket.bucket_id
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket."
  value       = module.tf_aws_s3_bucket.bucket_arn
}

output "bucket_regional_domain_name" {
  description = "Regional bucket domain name."
  value       = module.tf_aws_s3_bucket.bucket_regional_domain_name
}

output "kms_key_arn" {
  description = "KMS key ARN used for bucket encryption."
  value       = module.tf_aws_s3_bucket.kms_key_arn
}
