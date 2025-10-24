locals {
  name = var.project_name
}

# VPC module (simple)
module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
  public_subnets = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs
  project = local.name
}

# ECR repo for app images
resource "aws_ecr_repository" "app" {
  name = "${local.name}-app"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = false }
  tags = { Project = local.name }
}

# ECS Cluster
module "ecs" {
  source = "./modules/ecs"
  cluster_name = "${local.name}-ecs-cluster"
  vpc_id = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  public_subnets = module.vpc.public_subnets
  project = local.name
}

# RDS (MySQL db.t3.micro)
#module "rds" {
#  source = "./modules/rds"
#  project = local.name
#  vpc_security_group_ids = [module.vpc.default_sg_id]
#  subnet_ids = module.vpc.private_subnets
#  db_username = var.db_username
#  db_password = var.db_password
#}

# IAM roles for tasks and lambdas
module "iam" {
  source = "./modules/iam"
  project = local.name
}

# Lambda + DynamoDB
module "lambda" {
  source = "./modules/lambda"
  project = local.name
  lambda_s3_key_prefix = "lambda-artifacts/"
}

module "dynamodb" {
  source  = "./modules/dynamodb"
  project = local.name
}

locals {
  soar_env = {
    EVENT_TABLE  = module.dynamodb.dynamodb_table_name
    BLOCKED_TABLE = module.dynamodb.dynamodb_table_name
  }
}

