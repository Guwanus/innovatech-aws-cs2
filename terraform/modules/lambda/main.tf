resource "aws_dynamodb_table" "blocked_ips" {
  name         = "${var.project}-blockedips"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ip"
  attribute {
    name = "ip"
    type = "S"
  }
  tags = { Project = var.project }
}

output "dynamodb_table_name" { value = aws_dynamodb_table.blocked_ips.name }
