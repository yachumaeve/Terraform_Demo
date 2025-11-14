variable "ak" {
  type        = string
  description = "access_key"
}

variable "sk" {
  type        = string
  description = "secret_key"
}

variable "vpc_id" {
  type = string
  description = "the ID of the VPC "
}

variable "private_subnet_id" {
  type = list(string)
}

variable "public_subnets_id" {
  type = list(string)
}