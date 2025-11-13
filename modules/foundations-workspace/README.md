# Foundations Workspace Module

This module creates the foundational infrastructure for a workspace. A workspace represents a logical grouping of BFFs (Backend for Frontend) services that share common infrastructure like centralized logging.

## What's Included

- **Centralized API Gateway Logs**: A shared CloudWatch log group where all BFFs in the workspace write their API Gateway logs
- **Common Tagging**: Consistent tagging across all workspace resources

## Usage

```hcl
module "workspace" {
  source = "../modules/foundations-workspace"

  workspace_name      = "nonprod-user-repo"
  log_retention_days  = 30

  tags = {
    Environment = "nonprod"
    Team        = "platform"
  }
}

# Then use the workspace in your BFFs
module "homepage_bff" {
  source = "./bffs/homepage-bff"

  env_type                    = "nonprod"
  workspace_api_log_group_arn = module.workspace.workspace_api_log_group_arn
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| workspace_name | Name of the workspace | `string` | n/a | yes |
| log_retention_days | Number of days to retain API Gateway logs | `number` | `30` | no |
| tags | Additional tags to apply to all workspace resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| workspace_name | The name of the workspace |
| workspace_api_log_group_arn | ARN of the centralized API Gateway log group |
| workspace_api_log_group_name | Name of the centralized API Gateway log group |

## Design Principles

1. **Workspace as a Boundary**: Each workspace provides isolation and organization for related BFFs
2. **Shared Resources**: Common infrastructure (like logs) is centralized to reduce costs and improve observability
3. **Extensibility**: Easy to add more foundational components (VPCs, security groups, etc.) as needed
