variable "azs" {
  type = list(string)
}

variable "vpc_name" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "cidr" {
  type = string
}

variable "tags" {
  type = map(string)
}
