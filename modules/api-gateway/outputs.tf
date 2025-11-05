output "api_id" {
  description = "ID of the API Gateway"
  value       = module.api_gateway.api_id
}

output "api_endpoint" {
  description = "Endpoint URL of the API Gateway"
  value       = module.api_gateway.api_endpoint
}

output "api_execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = module.api_gateway.api_execution_arn
}

output "default_stage_id" {
  description = "ID of the default stage"
  value       = module.api_gateway.default_stage_id
}

output "default_stage_invoke_url" {
  description = "Invoke URL of the default stage"
  value       = module.api_gateway.default_stage_invoke_url
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.api_gateway_log_group.name
}

output "default_stage_execution_arn" {
  description = "Execution ARN of the default stage"
  value       = module.api_gateway.default_stage_execution_arn
}
