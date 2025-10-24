variable "project" {}
variable "subnet_ids" { type = list(string) }
variable "vpc_security_group_ids" { type = list(string) }
variable "db_username" {}
variable "db_password" { sensitive = true }
