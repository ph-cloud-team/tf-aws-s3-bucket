############################################
# Local values for tf-aws-s3-bucket
############################################

locals {
  module_name = "tf-aws-s3-bucket"
  common_tags = merge(
    {
      ManagedBy = "terraform"
      Module    = local.module_name
    },
    var.tags
  )

  bucket_kms_key_arn = var.create_kms_key ? aws_kms_key.this[0].arn : var.kms_key_arn
  bucket_policy_enabled = (
    var.attach_deny_insecure_transport_policy ||
    var.minimum_tls_version != null ||
    var.bucket_policy_json != null
  )
  effective_kms_alias = coalesce(var.kms_key_alias, replace(coalesce(var.bucket_name, var.bucket_name_prefix, "s3-bucket"), "/[^a-z0-9/_-]/", "-"))
}
