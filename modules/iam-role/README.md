# IAM Module

This module creates IAM roles and policies for Lambda functions.

## Features

- Creates IAM role with Lambda assume role policy
- Optionally accepts custom IAM policy JSON
- Attaches AWS managed AWSLambdaBasicExecutionRole policy
- Supports custom tagging

## Usage

```hcl
module "iam" {
  source = "../../devops/modules/iam"

  role_name          = "my-lambda-role"
  custom_policy_json = jsonencode({...})

  tags = {
    Environment = "dev"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| role_name | Name of the IAM role | string | n/a | yes |
| custom_policy_json | Custom IAM policy JSON | string | null | no |
| tags | Tags to apply to resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| role_arn | ARN of the IAM role |
| role_name | Name of the IAM role |
| role_id | ID of the IAM role |
| policy_attachment_id | ID of the policy attachment |
