# Lambda function
resource "aws_lambda_function" "this" {
  filename         = var.filename
  function_name    = var.function_name
  role            = var.role_arn
  handler         = var.handler
  runtime         = var.runtime
  timeout         = var.timeout
  memory_size     = var.memory_size
  source_code_hash = var.ignore_source_code_hash ? null : filebase64sha256(var.filename)
  description     = var.description

  environment {
    variables = var.environment_variables
  }

  depends_on = var.depends_on_resources

  tags = var.tags

  lifecycle {
    ignore_changes = var.ignore_source_code_hash ? [source_code_hash] : []
  }
}
