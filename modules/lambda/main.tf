# Lambda function
resource "aws_lambda_function" "this" {
  filename         = var.filename
  function_name    = var.function_name
  role            = var.role_arn
  handler         = var.handler
  runtime         = var.runtime
  timeout         = var.timeout
  memory_size     = var.memory_size
  source_code_hash = filebase64sha256(var.filename)
  description     = var.description

  environment {
    variables = var.environment_variables
  }

  tags = var.tags

  # Ignore source code changes - deployments handled separately
  lifecycle {
    ignore_changes = [source_code_hash]
  }
}
