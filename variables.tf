locals {
  default_tags = {
    Name     = "RainyEvening"
    Owner    = "Yuniia Olkhova"
    Reviewer = "Anton Pomieshchenko"
  }
  vpc_cidr = "10.0.1.0/24"
  subnet_cidr = "10.0.1.0/16"
}

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "environment" {
  type    = string
  default = "dev"
}