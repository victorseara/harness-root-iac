# Lambda Function Module

This module is a wrapper around the official [terraform-aws-modules/lambda/aws](https://github.com/terraform-aws-modules/terraform-aws-lambda) module, providing a simplified interface for deploying Lambda functions.

## Features

- Uses the battle-tested official AWS Lambda Terraform module
- Simplified configuration for common use cases
- Built-in IAM role creation
- Optional custom IAM policies
- Optional API Gateway invoke permissions
- Support for existing deployment packages
- **Separates infrastructure from deployments** - code changes are ignored by default

## Usage

```hcl
module "my_lambda" {
  source = "./modules/lambda"

  function_name = "my-express-app"
  description   = "Express.js application running on Lambda"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  filename      = "./path/to/deployment-package.zip"

  timeout     = 30
  memory_size = 512

  environment_variables = {
    NODE_ENV = "production"
    API_KEY  = "your-api-key"
  }

  # If using with API Gateway
  create_api_gateway_permission = true
  api_gateway_execution_arn     = "${module.api_gateway.api_execution_arn}/*"

  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

## Complete Example with API Gateway

```hcl
# Lambda function
module "express_lambda" {
  source = "./modules/lambda"

  function_name = "my-express-app"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  filename      = "./dist/lambda.zip"

  timeout     = 30
  memory_size = 512

  create_api_gateway_permission = true
  api_gateway_execution_arn     = "${module.api_gateway.api_execution_arn}/*"

  environment_variables = {
    NODE_ENV = "production"
  }

  tags = {
    Environment = "production"
  }
}

# API Gateway
module "api_gateway" {
  source = "./modules/api-gateway"

  api_name   = "my-express-api"
  lambda_arn = module.express_lambda.function_arn

  cors_allow_origins = ["https://example.com"]

  tags = {
    Environment = "production"
  }
}

output "api_url" {
  value = module.api_gateway.default_stage_invoke_url
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| function_name | Name of the Lambda function | string | - | yes |
| description | Description of the Lambda function | string | "" | no |
| handler | Lambda function handler | string | "index.handler" | no |
| runtime | Lambda runtime | string | "nodejs20.x" | no |
| timeout | Function timeout in seconds | number | 30 | no |
| memory_size | Memory size in MB | number | 128 | no |
| filename | Path to the Lambda deployment package (zip file) | string | - | yes |
| environment_variables | Environment variables for the Lambda function | map(string) | {} | no |
| role_name | Name of the IAM role (defaults to {function_name}-role) | string | null | no |
| tags | Tags to apply to resources | map(string) | {} | no |
| custom_policy_json | Custom IAM policy JSON for the Lambda function | string | null | no |
| create_api_gateway_permission | Whether to create API Gateway invoke permission | bool | false | no |
| api_gateway_execution_arn | ARN of the API Gateway execution | string | null | no |
| ignore_source_code_hash | Whether to ignore changes to source code hash | bool | true | no |

## Outputs

| Name | Description |
|------|-------------|
| function_name | Name of the Lambda function |
| function_arn | ARN of the Lambda function |
| invoke_arn | Invoke ARN of the Lambda function |
| role_arn | ARN of the Lambda IAM role |
| role_name | Name of the Lambda IAM role |
| qualified_arn | Qualified ARN of the Lambda function |
| version | Latest published version of the Lambda function |

## Notes

- This module uses the official terraform-aws-modules/lambda/aws module (version ~> 7.0)
- Use `custom_policy_json` to add additional permissions (e.g., DynamoDB, S3 access)
- When using with API Gateway, make sure to append `/*` to the execution ARN for the permission

## Infrastructure vs Deployment Strategy

This module is designed with a **separation of concerns** between infrastructure provisioning and code deployments:

### Initial Deployment
Terraform provisions the Lambda function with the initial code package specified in `filename`.

### Subsequent Code Updates
**By default, Terraform ignores code changes** (`ignore_source_code_hash = true`). This means:
- Infrastructure changes (memory, timeout, environment variables) are still managed by Terraform
- Code deployments should be handled outside of Terraform using:
  - AWS CLI: `aws lambda update-function-code`
  - CI/CD pipelines (GitHub Actions, GitLab CI, etc.)
  - AWS CodeDeploy
  - Deployment tools like `serverless`, `aws-sam`, or custom scripts

### Example Deployment Script
```bash
#!/bin/bash
# Deploy new code without Terraform
aws lambda update-function-code \
  --function-name my-express-app \
  --zip-file fileb://./dist/lambda.zip
```

### When to Set `ignore_source_code_hash = false`
Only set this to `false` if you want Terraform to manage code deployments. This is useful for:
- Development environments
- Simple projects without CI/CD pipelines
- When you want every `terraform apply` to deploy new code

### Best Practices
1. **Production**: Keep `ignore_source_code_hash = true` (default) and use CI/CD for deployments
2. **Development**: Consider setting `ignore_source_code_hash = false` for rapid iteration
3. **Environment Variables**: Continue managing these through Terraform as they're infrastructure concerns
4. **Version Control**: Use Lambda versions and aliases for blue/green deployments (managed outside Terraform)

## Advanced Configuration

For more advanced use cases, you can reference the [official module documentation](https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest) for additional configuration options.
