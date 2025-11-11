output "api_id" {
  description = "ID of the API Gateway"
  value       = aws_apigatewayv2_api.this.id
}

output "api_endpoint" {
  description = "Endpoint URL of the API Gateway"
  value       = aws_apigatewayv2_api.this.api_endpoint
}

output "api_execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_apigatewayv2_api.this.execution_arn
}

output "default_stage_id" {
  description = "ID of the default stage"
  value       = aws_apigatewayv2_stage.default.id
}

output "default_stage_invoke_url" {
  description = "Invoke URL of the default stage"
  value       = aws_apigatewayv2_stage.default.invoke_url
}

output "default_stage_execution_arn" {
  description = "Execution ARN of the default stage"
  value       = aws_apigatewayv2_stage.default.execution_arn
}
