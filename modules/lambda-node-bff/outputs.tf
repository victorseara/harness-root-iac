output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = local.lambda_function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = local.lambda_function_arn
}

output "lambda_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = local.lambda_invoke_arn
}

output "lambda_role_arn" {
  description = "ARN of the Lambda IAM role"
  value       = module.role.role_arn
}

output "lambda_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = module.logs.log_group_name
}

output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = module.api_gateway.api_id
}

output "api_gateway_endpoint" {
  description = "Endpoint URL of the API Gateway"
  value       = module.api_gateway.api_endpoint
}

output "api_gateway_invoke_url" {
  description = "Invoke URL of the API Gateway"
  value       = module.api_gateway.default_stage_invoke_url
}

output "api_gateway_execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = module.api_gateway.api_execution_arn
}

output "lambda_role_name" {
  description = "Name of the Lambda IAM role"
  value       = module.role.role_name
}

output "secrets" {
  description = "Map of created secrets with their ARNs"
  value = {
    for key, secret in module.secrets :
    key => {
      arn  = secret.secret_arn
      name = secret.secret_name
    }
  }
  sensitive = true
}

# Note: API Gateway log group is created at workspace level (infra/main.tf)
# and shared across all BFFs in the workspace
