variable "security_group" {
  type = string
}

variable "tags" {
  type = map(any)
}

variable "vpc_id" {
  type = string
}

variable "vpn_client_cidr" {
  type    = string
  default = "10.1.0.0/22"
}

variable "subnet_name_filter" {
  type    = string
  default = "*private*"
}
