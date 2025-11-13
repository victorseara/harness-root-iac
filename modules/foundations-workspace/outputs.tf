output "workspace_name" {
  description = "The name of the workspace"
  value       = var.workspace_name
}

output "workspace_api_log_group_arn" {
  description = "ARN of the centralized API Gateway log group for this workspace"
  value       = module.workspace_api_logs.log_group_arn
}

output "workspace_api_log_group_name" {
  description = "Name of the centralized API Gateway log group for this workspace"
  value       = module.workspace_api_logs.log_group_name
}
