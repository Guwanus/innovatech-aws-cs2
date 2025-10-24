resource "aws_dynamodb_table" "soar_events" {
  name         = "${var.project}-events"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "event_id"

  attribute {
    name = "event_id"
    type = "S"
  }

  tags = { Project = var.project }
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.soar_events.name
}
