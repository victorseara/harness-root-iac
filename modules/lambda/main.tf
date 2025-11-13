# Lambda function WITH source code tracking (Terraform manages deployments)
resource "aws_lambda_function" "terraform_managed" {
  count = var.ignore_source_code_changes ? 0 : 1

  filename                       = var.filename
  function_name                  = var.function_name
  role                          = var.role_arn
  handler                       = var.handler
  runtime                       = var.runtime
  timeout                       = var.timeout
  memory_size                   = var.memory_size
  source_code_hash              = filebase64sha256(var.filename)
  description                   = var.description
  reserved_concurrent_executions = var.reserved_concurrent_executions
  architectures                 = var.architectures
  layers                        = var.layers
  publish                       = var.publish

  # Environment variables (only create block if not empty)
  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [1] : []
    content {
      variables = var.environment_variables
    }
  }

  # Ephemeral storage configuration
  ephemeral_storage {
    size = var.ephemeral_storage_size
  }

  # Dead Letter Queue configuration
  dynamic "dead_letter_config" {
    for_each = var.dead_letter_target_arn != null ? [1] : []
    content {
      target_arn = var.dead_letter_target_arn
    }
  }

  tags = var.tags

  # No lifecycle block - Terraform tracks source_code_hash changes
}

# Lambda function WITHOUT source code tracking (separate deployment pipeline)
resource "aws_lambda_function" "external_deployment" {
  count = var.ignore_source_code_changes ? 1 : 0

  filename                       = var.filename
  function_name                  = var.function_name
  role                          = var.role_arn
  handler                       = var.handler
  runtime                       = var.runtime
  timeout                       = var.timeout
  memory_size                   = var.memory_size
  source_code_hash              = filebase64sha256(var.filename)
  description                   = var.description
  reserved_concurrent_executions = var.reserved_concurrent_executions
  architectures                 = var.architectures
  layers                        = var.layers
  publish                       = var.publish

  # Environment variables (only create block if not empty)
  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [1] : []
    content {
      variables = var.environment_variables
    }
  }

  # Ephemeral storage configuration
  ephemeral_storage {
    size = var.ephemeral_storage_size
  }

  # Dead Letter Queue configuration
  dynamic "dead_letter_config" {
    for_each = var.dead_letter_target_arn != null ? [1] : []
    content {
      target_arn = var.dead_letter_target_arn
    }
  }

  tags = var.tags

  # Lifecycle: ignore source_code_hash for separate deployment pipelines
  lifecycle {
    ignore_changes = [source_code_hash]
  }
}

# Local value to reference the correct Lambda function
locals {
  function_arn        = var.ignore_source_code_changes ? one(aws_lambda_function.external_deployment[*].arn) : one(aws_lambda_function.terraform_managed[*].arn)
  function_name       = var.ignore_source_code_changes ? one(aws_lambda_function.external_deployment[*].function_name) : one(aws_lambda_function.terraform_managed[*].function_name)
  invoke_arn          = var.ignore_source_code_changes ? one(aws_lambda_function.external_deployment[*].invoke_arn) : one(aws_lambda_function.terraform_managed[*].invoke_arn)
  qualified_arn       = var.ignore_source_code_changes ? one(aws_lambda_function.external_deployment[*].qualified_arn) : one(aws_lambda_function.terraform_managed[*].qualified_arn)
  qualified_invoke_arn = var.ignore_source_code_changes ? one(aws_lambda_function.external_deployment[*].qualified_invoke_arn) : one(aws_lambda_function.terraform_managed[*].qualified_invoke_arn)
  version             = var.ignore_source_code_changes ? one(aws_lambda_function.external_deployment[*].version) : one(aws_lambda_function.terraform_managed[*].version)
  last_modified       = var.ignore_source_code_changes ? one(aws_lambda_function.external_deployment[*].last_modified) : one(aws_lambda_function.terraform_managed[*].last_modified)
}
