locals {
  resource_prefix           = "mwaa-practice-"
  normalized_environment_id = replace(var.environment_id, "/", "--")
  mwaa_environment_name     = "${local.resource_prefix}${local.normalized_environment_id}"
  mwaa_environment_arn      = "arn:aws:airflow:${var.aws_region_name}:${var.aws_account_id}:environment/${local.mwaa_environment_name}"
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
      local.mwaa_environment_arn,
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
      "arn:aws:logs:${var.aws_region_name}:${var.aws_account_id}:log-group:airflow-${local.mwaa_environment_name}-*"
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
      test     = "StringLike"
      variable = "kms:ViaService"
      values = [
        "sqs.${var.aws_region_name}.amazonaws.com",
        "s3.${var.aws_region_name}.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_policy" "this" {
  name   = "${local.mwaa_environment_name}-basic"
  policy = data.aws_iam_policy_document.execution-role-basic-policy.json
}

resource "aws_iam_role" "this" {
  name               = local.mwaa_environment_name
  assume_role_policy = data.aws_iam_policy_document.airflow-assume-role.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_mwaa_environment" "this" {
  name               = local.mwaa_environment_name
  dag_s3_path        = "${var.environment_id}/dags/"
  execution_role_arn = aws_iam_role.this.arn
  environment_class  = "mw1.small"

  network_configuration {
    security_group_ids = var.security_group_ids
    subnet_ids         = var.subnet_ids
  }

  source_bucket_arn = var.source_bucket_arn

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

  depends_on = [
    aws_iam_role_policy_attachment.this,
  ]
}
