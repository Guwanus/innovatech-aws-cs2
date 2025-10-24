output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

#output "rds_endpoint" {
#  value = module.rds.address
#}

output "dynamodb_table" {
  value = module.lambda.dynamodb_table_name
}
