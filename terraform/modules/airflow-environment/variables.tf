variable "aws_account_id" {
  type = string
}

variable "aws_region_name" {
  type = string
}

variable "environment_id" {
  type = string
}

variable "source_bucket_arn" {
  type = string
}

variable "webserver_access_mode" {
  type    = string
  default = "PRIVATE_ONLY"
}

variable "security_group_ids" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}
