variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "project_name" {
  type    = string
  default = "cs2-ma-nca"
}

variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.10.1.0/24","10.10.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.10.11.0/24","10.10.12.0/24"]
}

variable "db_username" {
  type    = string
  default = "soar_admin"
}

variable "db_password" {
  description = "RDS master password (set via TF var or secrets manager)"
  type = string
  sensitive = true
}

variable "app_image_tag" {
  type    = string
  default = "latest"
}
