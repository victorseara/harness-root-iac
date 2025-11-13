output "function_name" {
  description = "Name of the Lambda function"
  value       = local.function_name
}

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = local.function_arn
}

output "invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = local.invoke_arn
}

output "qualified_arn" {
  description = "Qualified ARN of the Lambda function"
  value       = local.qualified_arn
}

output "qualified_invoke_arn" {
  description = "Qualified invoke ARN of the Lambda function"
  value       = local.qualified_invoke_arn
}

output "version" {
  description = "Latest published version of the Lambda function"
  value       = local.version
}

output "last_modified" {
  description = "Date this resource was last modified"
  value       = local.last_modified
}
