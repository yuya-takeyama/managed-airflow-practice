variable "environment_name" {
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
