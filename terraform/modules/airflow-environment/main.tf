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

resource "aws_iam_role_policy_attachment" "execution-role-basic-policy" {
  role       = aws_iam_role.this.name
  policy_arn = var.execution_role_basic_policy_arn
}

resource "aws_mwaa_environment" "this" {
  name               = "managed-airflow-practice-${replace(var.environment_name, "/", "--")}"
  dag_s3_path        = "${var.environment_name}/dags/"
  execution_role_arn = aws_iam_role.this.arn

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
