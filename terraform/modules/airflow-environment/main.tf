locals {
  normalized_environment_name = replace(var.environment_name, "/", "--")
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

data "aws_iam_policy_document" "execution-role-basic-policy" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "airflow:PublishMetrics",
    ]
    resources = [
      aws_mwaa_environment.this.arn,
    ]
  }

  statement {
    effect = "Deny"
    actions = [
      "s3:ListAllMyBuckets"
    ]
    resources = [
      var.source_bucket_arn,
      "${var.source_bucket_arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucket*",
      "s3:GetObject*",
      "s3:List*",
    ]
    resources = [
      var.source_bucket_arn,
      "${var.source_bucket_arn}/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:GetLogRecord",
      "logs:GetLogGroupFields",
      "logs:GetQueryResults",
      "logs:DescribeLogGroups",
    ]
    resources = [
      "arn:aws:logs:${var.aws_region_name}:${var.aws_account_id}:log-group:airflow-${aws_mwaa_environment.this.name}-*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData"
    ]
    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
    ]
    resources = [
      "arn:aws:sqs:${var.aws_region_name}:*:airflow-celery-*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
      "kms:Encrypt",
    ]
    not_resources = [
      "arn:aws:kms:*:${var.aws_account_id}:key/*"
    ]
    condition {
      test = "StringLike"
      variable = "kms:ViaService"
      values = [
        "sqs.${var.aws_region_name}.amazonaws.com",
        "s3.${var.aws_region_name}.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_policy" "execution-role-basic-policy" {
  name   = "managed-airflow-practice-${local.normalized_environment_name}-basic"
  policy = data.aws_iam_policy_document.execution-role-basic-policy.json
}

resource "aws_iam_role" "this" {
  name               = "airflow-environment-${local.normalized_environment_name}"
  assume_role_policy = data.aws_iam_policy_document.airflow-assume-role.json
}

resource "aws_iam_role_policy_attachment" "execution-role-basic-policy" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.execution-role-basic-policy.arn
}

resource "aws_mwaa_environment" "this" {
  name               = "managed-airflow-practice-${local.normalized_environment_name}"
  dag_s3_path        = "${var.environment_name}/dags/"
  execution_role_arn = aws_iam_role.this.arn
  environment_class  = "mw1.medium"

  network_configuration {
    security_group_ids = var.security_group_ids
    subnet_ids         = var.subnet_ids
  }

  source_bucket_arn = "arn:aws:s3:::yuyat-apache-airflow-test"

  webserver_access_mode = var.webserver_access_mode

  logging_configuration {
    dag_processing_logs {
      enabled   = true
      log_level = "INFO"
    }

    scheduler_logs {
      enabled   = true
      log_level = "INFO"
    }

    task_logs {
      enabled   = true
      log_level = "INFO"
    }

    webserver_logs {
      enabled   = true
      log_level = "INFO"
    }

    worker_logs {
      enabled   = true
      log_level = "INFO"
    }
  }
}
