# API Gateway HTTP API Module

This module is a wrapper around the official [terraform-aws-modules/apigateway-v2/aws](https://github.com/terraform-aws-modules/terraform-aws-apigateway-v2) module, providing a simplified interface for creating HTTP API Gateways that proxy all requests to a Lambda function. Perfect for Express.js applications with multiple routes.

## Features

- Uses the battle-tested official AWS API Gateway v2 Terraform module
- HTTP API Gateway (not REST API) - faster and cheaper
- Default route (`$default`) that proxies ALL requests to Lambda
- Automatic Lambda integration with AWS_PROXY
- Built-in CORS configuration
- CloudWatch logging with structured JSON logs
- Automatic deployment enabled

## Usage

```hcl
module "api_gateway" {
  source = "./modules/api-gateway"

  api_name   = "my-express-api"
  description = "API Gateway for Express.js application"
  lambda_arn = module.my_lambda.function_arn

  # CORS configuration
  cors_allow_origins  = ["https://example.com", "https://app.example.com"]
  cors_allow_methods  = ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"]
  cors_allow_headers  = ["Content-Type", "Authorization"]
  cors_allow_credentials = true

  log_retention_days = 14

  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

## Complete Example with Lambda

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

# Output the API URL
output "api_url" {
  value = module.api_gateway.default_stage_invoke_url
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| api_name | Name of the API Gateway | string | - | yes |
| description | Description of the API Gateway | string | "" | no |
| lambda_arn | ARN of the Lambda function (not invoke_arn) | string | - | yes |
| integration_timeout_ms | Integration timeout in milliseconds (50-30000) | number | 30000 | no |
| cors_allow_origins | CORS allowed origins | list(string) | ["*"] | no |
| cors_allow_methods | CORS allowed methods | list(string) | ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS", "HEAD"] | no |
| cors_allow_headers | CORS allowed headers | list(string) | ["*"] | no |
| cors_expose_headers | CORS exposed headers | list(string) | [] | no |
| cors_max_age | CORS max age in seconds | number | 300 | no |
| cors_allow_credentials | Whether to allow credentials in CORS | bool | false | no |
| log_retention_days | CloudWatch log retention in days | number | 7 | no |
| tags | Tags to apply to resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| api_id | ID of the API Gateway |
| api_endpoint | Endpoint URL of the API Gateway |
| api_execution_arn | Execution ARN of the API Gateway (use for Lambda permissions) |
| default_stage_id | ID of the default stage |
| default_stage_invoke_url | Full invoke URL of the default stage |
| log_group_name | Name of the CloudWatch log group |
| default_stage_execution_arn | Execution ARN of the default stage |

## How It Works

This module uses the `$default` route, which means:
- ALL HTTP methods (GET, POST, PUT, DELETE, etc.) are proxied to your Lambda
- ALL paths are proxied to your Lambda (e.g., `/users`, `/api/posts/123`, etc.)
- Your Express.js app receives the full request and handles routing internally

The Lambda integration uses:
- `AWS_PROXY` integration type
- Payload format version 2.0 (recommended for HTTP APIs)
- Configurable integration timeout (up to 30 seconds)

## Important Notes

- **Lambda ARN**: This module requires the Lambda function ARN (not the invoke ARN). Use `module.lambda.function_arn`
- **Lambda Permissions**: Make sure to set `create_api_gateway_permission = true` in the Lambda module and pass `${module.api_gateway.api_execution_arn}/*`
- **CORS**: CORS is configured at the API Gateway level for better performance
- **Logging**: CloudWatch logs are structured as JSON for easy parsing
- **Official Module**: This wrapper uses terraform-aws-modules/apigateway-v2/aws version ~> 5.0

## Advanced Configuration

For more advanced use cases (custom domains, authorizers, throttling, etc.), you can reference the [official module documentation](https://registry.terraform.io/modules/terraform-aws-modules/apigateway-v2/aws/latest) for additional configuration options.

## Express.js Compatibility

This module is designed to work seamlessly with Express.js applications deployed to Lambda. Make sure your Express app is wrapped with a Lambda handler (e.g., using `serverless-http` or `aws-serverless-express`):

```javascript
const serverless = require('serverless-http');
const express = require('express');
const app = express();

// Your Express routes
app.get('/api/users', (req, res) => {
  res.json({ users: [] });
});

app.post('/api/users', (req, res) => {
  res.json({ created: true });
});

// Export for Lambda
module.exports.handler = serverless(app);
```
