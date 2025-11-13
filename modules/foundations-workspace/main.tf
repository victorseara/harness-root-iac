# Centralized API Gateway logs for this workspace
# All BFFs in this workspace will log to this shared log group
module "workspace_api_logs" {
  source = "../cloudwatch"

  log_group_name    = "/aws/apigateway/${var.workspace_name}"
  retention_in_days = var.log_retention_days

  tags = merge(
    var.tags,
    {
      ManagedBy = "terraform"
      Workspace = var.workspace_name
    }
  )
}
