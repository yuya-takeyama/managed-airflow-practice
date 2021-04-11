resource "aws_codebuild_project" "terraform" {
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
    image                       = "hashicorp/terraform:0.14.3"
    image_pull_credentials_type = "SERVICE_ROLE"
    privileged_mode             = "false"
    type                        = "LINUX_CONTAINER"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "codebuild"
      status      = "ENABLED"
      stream_name = "managed-airflow-practice-terraform"
    }

    s3_logs {
      encryption_disabled = "false"
      status              = "DISABLED"
    }
  }

  name           = "managed-airflow-practice-terraform"
  queued_timeout = "480"
  service_role   = aws_iam_role.codebuild-terraform.arn

  source {
    buildspec       = ".codebuild/terraform.buildspec.yaml"
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

data "aws_iam_policy_document" "codebuild-terraform-assume-role" {
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

resource "aws_iam_role" "codebuild-terraform" {
  name               = "codebuild-managed-airflow-practice-terraform"
  assume_role_policy = data.aws_iam_policy_document.codebuild-terraform-assume-role.json
}

resource "aws_iam_role_policy_attachment" "codebuild-terraform" {
  role       = aws_iam_role.codebuild-terraform.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_codebuild_webhook" "terraform" {
  project_name = aws_codebuild_project.terraform.name

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }

    filter {
      type    = "FILE_PATH"
      pattern = "^(terraform|scripts/terraform)/.*"
    }
  }
}
