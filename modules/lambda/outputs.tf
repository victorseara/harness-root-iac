output "function_name" {
  description = "Name of the Lambda function"
  value       = module.lambda_function.lambda_function_name
}

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda_function.lambda_function_arn
}

output "invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = module.lambda_function.lambda_function_invoke_arn
}

output "role_arn" {
  description = "ARN of the Lambda IAM role"
  value       = module.lambda_function.lambda_role_arn
}

output "role_name" {
  description = "Name of the Lambda IAM role"
  value       = module.lambda_function.lambda_role_name
}

output "qualified_arn" {
  description = "Qualified ARN of the Lambda function"
  value       = module.lambda_function.lambda_function_qualified_arn
}

output "version" {
  description = "Latest published version of the Lambda function"
  value       = module.lambda_function.lambda_function_version
}
