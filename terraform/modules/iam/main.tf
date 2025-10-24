###########################
# IAM ROLES AND POLICIES
###########################

# ECS Task Execution Role
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.project}-ecs-task-exec-${random_string.suffix.result}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
  tags = { Project = var.project }
    force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_attach" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Lambda Execution Role (for serverless actions)
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = "${var.project}-lambda-exec"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
  tags = { Project = var.project }
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Optional: allow Lambda to write to DynamoDB for the block-IP action
resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name        = "${var.project}-lambda-dynamodb"
  description = "Allow Lambda to write to DynamoDB blocked-IP table"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

###########################
# OUTPUTS
###########################
output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution.arn
}

output "lambda_exec_role_arn" {
  value = aws_iam_role.lambda_exec.arn
}
