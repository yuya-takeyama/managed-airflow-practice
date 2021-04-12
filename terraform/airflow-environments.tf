locals {
  security_group_ids = [module.vpc.default_security_group_id]
  subnet_ids         = slice(module.vpc.private_subnets, 0, 2)
}

module "service-foo-staging" {
  source = "./modules/airflow-environment"

  environment_name = "service-foo/staging"

  security_group_ids = local.security_group_ids
  subnet_ids         = local.subnet_ids

  webserver_access_mode = "PUBLIC_ONLY"
}

module "service-foo-production" {
  source = "./modules/airflow-environment"

  environment_name = "service-foo/production"

  security_group_ids = local.security_group_ids
  subnet_ids         = local.subnet_ids

  webserver_access_mode = "PUBLIC_ONLY"
}
