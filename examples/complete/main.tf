module "tf_aws_s3_bucket" {
  source = "../../"

  bucket_name_prefix = var.bucket_name_prefix

  access_logging = {
    target_bucket = var.access_log_bucket_name
    target_prefix = "${var.application}/"
  }

  lifecycle_rules = [
    {
      id                                 = "enterprise-retention"
      enabled                            = true
      noncurrent_version_expiration_days = 90

      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 180
          storage_class = "GLACIER"
        }
      ]

      noncurrent_version_transitions = [
        {
          noncurrent_days = 30
          storage_class   = "STANDARD_IA"
        }
      ]
    }
  ]

  tags = {
    Name               = var.name
    Environment        = var.environment
    Owner              = var.owner
    CostCenter         = var.cost_center
    Application        = var.application
    DataClassification = var.data_classification
  }
}
