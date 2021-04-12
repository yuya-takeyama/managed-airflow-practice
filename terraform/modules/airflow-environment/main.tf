locals {
  source_bucket_arn = "arn:aws:s3:::yuyat-apache-airflow-test"
}

data "aws_iam_policy_document" "airflow-assume-role" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "airflow-env.amazonaws.com",
        "airflow.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "airflow-environment-${replace(var.environment_name, "/", "--")}"
  assume_role_policy = data.aws_iam_policy_document.airflow-assume-role.json
}

data "aws_iam_policy_document" "s3" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucket*",
      "s3:GetObject*",
      "s3:List*",
    ]
    resources = [
      local.source_bucket_arn,
      "${local.source_bucket_arn}/*",
    ]
  }
}

resource "aws_iam_policy" "s3" {
  name   = "managed-airflow-practice-airflow-environment-s3"
  policy = data.aws_iam_policy_document.s3.json
}

resource "aws_iam_role_policy_attachment" "s3" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.s3.arn
}

resource "aws_mwaa_environment" "this" {
  dag_s3_path        = "${var.environment_name}/dags/"
  execution_role_arn = aws_iam_role.this.arn
  name               = "managed-airflow-practice-${replace(var.environment_name, "/", "--")}"

  network_configuration {
    security_group_ids = var.security_group_ids
    subnet_ids         = var.subnet_ids
  }

  source_bucket_arn = local.source_bucket_arn

  webserver_access_mode = var.webserver_access_mode
}
