resource "aws_codebuild_project" "airflow" {
  artifacts {
    encryption_disabled    = "false"
    override_artifact_name = "false"
    type                   = "NO_ARTIFACTS"
  }

  badge_enabled = "false"
  build_timeout = "60"

  cache {
    type = "NO_CACHE"
  }

  description    = "https://github.com/yuya-takeyama/managed-airflow-practice"
  encryption_key = "arn:aws:kms:ap-northeast-1:711930837542:alias/aws/s3"

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = "false"
    type                        = "LINUX_CONTAINER"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "codebuild"
      status      = "ENABLED"
      stream_name = "managed-airflow-practice-airflow"
    }

    s3_logs {
      encryption_disabled = "false"
      status              = "DISABLED"
    }
  }

  name           = "managed-airflow-practice-airflow"
  queued_timeout = "480"
  service_role   = aws_iam_role.codebuild-airflow.arn

  source {
    buildspec       = ".codebuild/airflow.buildspec.yaml"
    git_clone_depth = "1"

    git_submodules_config {
      fetch_submodules = "false"
    }

    insecure_ssl        = "false"
    location            = "https://github.com/yuya-takeyama/managed-airflow-practice.git"
    report_build_status = "true"
    type                = "GITHUB"
  }
}

data "aws_iam_policy_document" "codebuild-airflow-assume-role" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codebuild-airflow" {
  name               = "codebuild-managed-airflow-practice-airflow"
  assume_role_policy = data.aws_iam_policy_document.codebuild-airflow-assume-role.json
}

data "aws_iam_policy_document" "codebuild-airflow-basic" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      "arn:aws:s3:::yuyat-apache-airflow-test",
      "arn:aws:s3:::yuyat-apache-airflow-test/*",
    ]
  }
}

resource "aws_iam_policy" "codebuild-airflow-basic" {
  name   = "codebuild-managed-airflow-practice-airflow-basic"
  policy = data.aws_iam_policy_document.codebuild-airflow-basic.json
}

data "aws_iam_policy_document" "codebuild-airflow-s3" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      "arn:aws:s3:::yuyat-apache-airflow-test",
      "arn:aws:s3:::yuyat-apache-airflow-test/*",
    ]
  }
}

resource "aws_iam_policy" "codebuild-airflow-s3" {
  name   = "codebuild-managed-airflow-practice-airflow-s3"
  policy = data.aws_iam_policy_document.codebuild-airflow-s3.json
}

resource "aws_iam_role_policy_attachment" "codebuild-airflow-basic" {
  role       = aws_iam_role.codebuild-airflow.name
  policy_arn = aws_iam_policy.codebuild-airflow-basic.arn
}

resource "aws_iam_role_policy_attachment" "codebuild-airflow-s3" {
  role       = aws_iam_role.codebuild-airflow.name
  policy_arn = aws_iam_policy.codebuild-airflow-s3.arn
}

resource "aws_codebuild_webhook" "airflow" {
  project_name = aws_codebuild_project.airflow.name

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }

    filter {
      type    = "FILE_PATH"
      pattern = "^(environments|scripts/airflow)/.*"
    }
  }
}
