locals {
  aws_region_name = "ap-northeast-1"
  aws_account_id  = "711930837542"

  security_group_ids = [module.vpc.default_security_group_id]
  subnet_ids         = slice(module.vpc.private_subnets, 0, 2)
}

module "service-foo-production" {
  source = "./modules/airflow-environment"

  aws_region_name = local.aws_region_name
  aws_account_id  = local.aws_account_id

  environment_name  = "service-foo/production"
  source_bucket_arn = aws_s3_bucket.bucket.arn

  security_group_ids = local.security_group_ids
  subnet_ids         = local.subnet_ids

  webserver_access_mode = "PUBLIC_ONLY"
}

module "service-foo-staging" {
  source = "./modules/airflow-environment"

  aws_region_name = local.aws_region_name
  aws_account_id  = local.aws_account_id

  environment_name  = "service-foo/staging"
  source_bucket_arn = aws_s3_bucket.bucket.arn

  security_group_ids = local.security_group_ids
  subnet_ids         = local.subnet_ids

  webserver_access_mode = "PUBLIC_ONLY"
}
