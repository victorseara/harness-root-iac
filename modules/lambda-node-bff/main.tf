data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}"
  output_path = "${path.module}/.terraform/lambda-package.zip"

  excludes = [
    ".terraform",
    ".terraform.lock.hcl",
    "main.tf",
    "environment.tf",
    "variables.tf",
    "outputs.tf",
    "README.md",
    "versions.tf",
    ".git",
    "*.zip"
  ]
}

# Secrets Management (optional)
module "secrets" {
  for_each = var.secrets
  source   = "../secrets"

  secret_name             = "${var.app_name}-${each.key}"
  description             = each.value.description
  secret_string           = each.value.value
  recovery_window_in_days = each.value.recovery_window_in_days
  tags                    = var.tags
}

# CloudWatch Logs for Lambda
module "logs" {
  source = "../cloudwatch"

  log_group_name    = "/aws/lambda/${var.app_name}_function"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

# Note: Centralized API Gateway log group is created at the workspace level
# (in infra/main.tf) and passed to this module via var.centralized_api_log_group_arn

# IAM Role for Lambda
module "role" {
  source = "../iam-role"

  role_name                           = "${var.app_name}_role"
  service_principal                   = "lambda.amazonaws.com"
  attach_lambda_basic_execution_policy = true
  secrets_arns                        = [for secret in module.secrets : secret.secret_arn]
  tags                                = var.tags
}

# Lambda Function (skip creation if using existing Lambda)
module "lambda" {
  count  = var.existing_lambda_function_name == null ? 1 : 0
  source = "../lambda"

  function_name                  = "${var.app_name}_function"
  description                    = var.description
  handler                        = var.lambda_handler
  runtime                        = var.lambda_runtime
  filename                       = data.archive_file.lambda_zip.output_path
  role_arn                       = module.role.role_arn
  timeout                        = var.lambda_timeout
  memory_size                    = var.lambda_memory_size
  reserved_concurrent_executions = var.reserved_concurrent_executions
  dead_letter_target_arn         = var.dead_letter_target_arn
  ignore_source_code_changes     = var.ignore_source_code_changes

  environment_variables = merge(
    var.environment_variables,
    {
      for key, secret in module.secrets :
      "${upper(key)}_SECRET_ARN" => secret.secret_arn
    }
  )

  tags = var.tags

  depends_on = [
    module.logs,
    module.role
  ]
}

# Data source for existing Lambda (for migration scenarios)
data "aws_lambda_function" "existing" {
  count         = var.existing_lambda_function_name != null ? 1 : 0
  function_name = var.existing_lambda_function_name
}

# Local values to handle both new and existing Lambda
locals {
  lambda_function_name = var.existing_lambda_function_name != null ? var.existing_lambda_function_name : "${var.app_name}_function"
  lambda_function_arn  = var.existing_lambda_function_name != null ? one(data.aws_lambda_function.existing[*].arn) : one(module.lambda[*].function_arn)
  lambda_invoke_arn    = var.existing_lambda_function_name != null ? one(data.aws_lambda_function.existing[*].invoke_arn) : one(module.lambda[*].invoke_arn)
}

# API Gateway
module "api_gateway" {
  source = "../api-gateway-http"

  api_name                   = "${var.app_name}_api"
  description                = var.api_gateway_description != "" ? var.api_gateway_description : "API Gateway for ${var.app_name}_function"
  lambda_invoke_arn          = local.lambda_invoke_arn
  cors_allow_origins         = var.cors_allow_origins
  cors_allow_methods         = var.cors_allow_methods
  cors_allow_headers         = var.cors_allow_headers
  cors_expose_headers        = var.cors_expose_headers
  cors_max_age               = var.cors_max_age
  cors_allow_credentials     = var.cors_allow_credentials
  integration_timeout_ms     = var.integration_timeout_ms
  throttling_burst_limit     = var.throttling_burst_limit
  throttling_rate_limit      = var.throttling_rate_limit
  access_log_destination_arn = var.centralized_api_log_group_arn

  # Use generic additional_log_fields instead of BFF-specific variables
  additional_log_fields = {
    bff_name    = var.bff_name != "" ? var.bff_name : var.app_name
    environment = var.environment
  }

  tags = var.tags
}

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = local.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.api_execution_arn}/*/*"
}
