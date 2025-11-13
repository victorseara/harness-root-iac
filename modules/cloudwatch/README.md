# CloudWatch Module

This module creates CloudWatch log groups for Lambda functions and API Gateway.

## Features

- Creates CloudWatch log group with configurable retention
- Supports custom tagging

## Usage

```hcl
module "cloudwatch" {
  source = "../../devops/modules/cloudwatch"

  log_group_name   = "/aws/lambda/my-function"
  retention_in_days = 14

  tags = {
    Environment = "dev"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| log_group_name | Name of the CloudWatch log group | string | n/a | yes |
| retention_in_days | Log retention in days | number | 14 | no |
| tags | Tags to apply to resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| log_group_name | Name of the CloudWatch log group |
| log_group_arn | ARN of the CloudWatch log group |
| log_group_id | ID of the CloudWatch log group |
