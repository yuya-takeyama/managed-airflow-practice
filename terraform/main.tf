module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "airflow-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket        = "yuyat-apache-airflow-test"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "execution-role-basic-policy" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucket*",
      "s3:GetObject*",
      "s3:List*",
    ]
    resources = [
      "arn:aws:s3:::yuyat-apache-airflow-test",
      "arn:aws:s3:::yuyat-apache-airflow-test/*",
    ]
  }
}

resource "aws_iam_policy" "execution-role-basic-policy" {
  name   = "managed-airflow-practice-airflow-executioin-role-basic-policy"
  policy = data.aws_iam_policy_document.execution-role-basic-policy.json
}

