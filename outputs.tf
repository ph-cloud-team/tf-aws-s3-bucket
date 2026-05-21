############################################
# Outputs for tf-aws-s3-bucket
############################################

output "module_name" {
  description = "Name of the Terraform module."
  value       = local.module_name
}

output "bucket_id" {
  description = "Name of the S3 bucket."
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket."
  value       = aws_s3_bucket.this.arn
}

output "bucket_domain_name" {
  description = "Global bucket domain name."
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Regional bucket domain name."
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "bucket_hosted_zone_id" {
  description = "Route 53 hosted zone ID for the bucket region."
  value       = aws_s3_bucket.this.hosted_zone_id
}

output "bucket_region" {
  description = "AWS region where the bucket was created."
  value       = aws_s3_bucket.this.region
}

output "kms_key_arn" {
  description = "KMS key ARN used for default bucket encryption."
  value       = local.bucket_kms_key_arn
}

output "kms_key_id" {
  description = "Created KMS key ID, or null when an external key is used."
  value       = var.create_kms_key ? aws_kms_key.this[0].key_id : null
}

output "bucket_policy_json" {
  description = "Rendered bucket policy JSON when a bucket policy is attached."
  value       = local.bucket_policy_enabled ? data.aws_iam_policy_document.bucket[0].json : null
}
