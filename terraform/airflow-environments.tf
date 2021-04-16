locals {
  security_group_ids = [module.vpc.default_security_group_id]
  subnet_ids         = slice(module.vpc.private_subnets, 0, 2)

  execution_role_basic_policy_arn = aws_iam_policy.execution-role-basic-policy.arn
}

module "service-foo-production" {
  source = "./modules/airflow-environment"

  environment_name = "service-foo/production"

  security_group_ids = local.security_group_ids
  subnet_ids         = local.subnet_ids

  execution_role_basic_policy_arn = local.execution_role_basic_policy_arn

  webserver_access_mode = "PUBLIC_ONLY"
}
