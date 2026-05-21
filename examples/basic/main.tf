module "tf_aws_s3_bucket" {
  source = "../../"

  bucket_name_prefix = var.bucket_name_prefix
  create_kms_key     = false
  kms_key_arn        = var.kms_key_arn

  access_logging = {
    target_bucket = var.access_log_bucket_name
    target_prefix = "${var.application}/"
  }

  tags = {
    Name               = var.name
    Environment        = var.environment
    Owner              = var.owner
    CostCenter         = var.cost_center
    Application        = var.application
    DataClassification = var.data_classification
  }
}
