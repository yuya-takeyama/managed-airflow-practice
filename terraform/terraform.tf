terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.36"
    }
  }

  backend "s3" {
    bucket         = "yuyat-managed-airflow-practice-tfstate"
    key            = "terraform.tfstate"
    dynamodb_table = "managed-airflow-practice-lock"
    region         = "ap-northeast-1"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-northeast-1"
}
