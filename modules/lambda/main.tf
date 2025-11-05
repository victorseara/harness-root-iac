module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"

  function_name = var.function_name
  description   = var.description
  handler       = var.handler
  runtime       = var.runtime
  timeout       = var.timeout
  memory_size   = var.memory_size

  create_package         = false
  local_existing_package = var.filename

  environment_variables = var.environment_variables

  # Ignore code changes - deployments handled outside Terraform
  ignore_source_code_hash = var.ignore_source_code_hash

  # IAM
  create_role = true
  role_name   = var.role_name != null ? var.role_name : "${var.function_name}-role"
  attach_cloudwatch_logs_policy = true
  cloudwatch_logs_retention_in_days = var.log_retention_days

  # Additional policies
  attach_policy_json = var.custom_policy_json != null
  policy_json        = var.custom_policy_json

  # API Gateway permissions
  create_lambda_function_url = false

  allowed_triggers = var.create_api_gateway_permission ? {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = var.api_gateway_execution_arn
    }
  } : {}

  tags = var.tags
}
