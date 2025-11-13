# Lambda Node BFF Module

**Production-ready** Node.js Backend-For-Frontend (BFF) module with AWS Lambda, API Gateway, and comprehensive security features.

## ✨ Features

- ✅ **Security Hardened**: Rate limiting, API access logging, concurrency limits, CORS configuration
- ✅ **Secrets Management**: AWS Secrets Manager integration with least-privilege IAM
- ✅ **Centralized Logging**: Workspace-level API Gateway logs with per-BFF filtering
- ✅ **Separate Deployment Pipelines**: Infrastructure and code fully decoupled (default)
- ✅ **Migration Support**: Use existing Lambdas with `existing_lambda_function_name`
- ✅ **Zero Code Required**: Placeholder Lambda included in module
- ✅ **DLQ Support**: Dead Letter Queue configuration for failed invocations

---

## 🚀 Quick Start

### New BFF (Recommended)

```hcl
module "my_bff" {
  source = "../../modules/lambda-node-bff"

  app_name = "my-bff-prod"

  # Security configuration
  cors_allow_origins     = ["https://yourdomain.com"]
  throttling_rate_limit  = 100
  throttling_burst_limit = 500
  reserved_concurrent_executions = 100

  # Centralized logging for filtering
  centralized_api_log_group_name = "/aws/apigateway/team-myteam"
  bff_name                       = "my-bff"
  environment                    = "prod"

  tags = {
    Environment = "prod"
    Team        = "myteam"
  }
}
```

**That's it!** The module provides a placeholder Lambda (`main.js`). Deploy your real application code via your CI/CD pipeline.

### Migrate Existing Lambda

```hcl
module "my_bff" {
  source = "../../modules/lambda-node-bff"

  app_name = "my-bff-prod"
  existing_lambda_function_name = "my-existing-lambda"  # ← Use existing Lambda

  # Add security features to existing Lambda
  cors_allow_origins     = ["https://yourdomain.com"]
  throttling_rate_limit  = 100
  centralized_api_log_group_name = "/aws/apigateway/team-myteam"
}
```

This **skips Lambda creation** and wraps your existing function with API Gateway + all security features.

---

## 📖 Complete Example

```hcl
# Centralized API Gateway logs for the workspace
resource "aws_cloudwatch_log_group" "workspace_api_logs" {
  name              = "/aws/apigateway/team-homepage"
  retention_in_days = 30
}

module "homepage_bff" {
  source   = "../../modules/lambda-node-bff"
  for_each = { dev = "dev", prod = "prod" }

  app_name    = "homepage-bff-${each.key}"
  description = "Homepage BFF (${each.key})"

  # Lambda configuration
  lambda_timeout                 = 30
  lambda_memory_size             = 512
  reserved_concurrent_executions = 100
  ignore_source_code_changes     = true  # Default - code via CI/CD

  # API Gateway security
  cors_allow_origins             = ["https://${each.key}.yourdomain.com"]
  throttling_rate_limit          = each.key == "prod" ? 200 : 50
  throttling_burst_limit         = each.key == "prod" ? 1000 : 100
  centralized_api_log_group_name = aws_cloudwatch_log_group.workspace_api_logs.name
  bff_name                       = "homepage-bff"
  environment                    = each.key

  # Secrets (optional)
  secrets = {
    api_key = {
      description             = "External API Key"
      value                   = "secret-value"  # Or use data source
      recovery_window_in_days = 30
    }
  }

  tags = {
    Environment = each.key
    BFF         = "homepage"
  }
}
```

---

## 📊 Centralized Logging & Filtering

All BFFs in a workspace share one API Gateway log group. Filter logs by BFF:

```bash
# CloudWatch Insights query
fields @timestamp, bff_name, environment, status, httpMethod, ip
| filter bff_name = "homepage-bff" and environment = "prod"
| sort @timestamp desc
```

Log entry includes:
- `bff_name`: "homepage-bff"
- `environment`: "prod"
- `status`: 200
- `httpMethod`: "GET"
- `ip`: Client IP
- `requestId`, `errorMessage`, etc.

---

## 🔐 Secrets Management

```hcl
secrets = {
  database_url = {
    description             = "Database connection string"
    value                   = data.aws_secretsmanager_secret_version.db.secret_string
    recovery_window_in_days = 30
  }
  api_key = {
    description             = "External API Key"
    value                   = "your-secret-value"
    recovery_window_in_days = 7
  }
}
```

Secrets are automatically:
- Created in AWS Secrets Manager
- Given IAM permissions to Lambda
- Exposed as environment variables: `DATABASE_URL_SECRET_ARN`, `API_KEY_SECRET_ARN`

**Accessing secrets in Lambda**:
```javascript
const { SecretsManagerClient, GetSecretValueCommand } = require("@aws-sdk/client-secrets-manager");

const secretArn = process.env.API_KEY_SECRET_ARN;
const client = new SecretsManagerClient({});
const response = await client.send(new GetSecretValueCommand({ SecretId: secretArn }));
const secret = response.SecretString;
```

---

## 🔄 Deployment Models

### Model 1: Separate Pipelines (Default - Recommended)

**Infrastructure** (Terraform):
```hcl
module "my_bff" {
  source = "../../modules/lambda-node-bff"
  app_name = "my-bff-prod"
  ignore_source_code_changes = true  # Default
}
```

**Code** (Your CI/CD):
```bash
# Deploy code updates via AWS CLI
aws lambda update-function-code \
  --function-name my-bff-prod_function \
  --zip-file fileb://app.zip
```

**Why?** Complete separation of infrastructure and code deployments.

### Model 2: Terraform-Managed Code (Legacy/Dev)

```hcl
module "my_bff" {
  source = "../../modules/lambda-node-bff"
  app_name = "my-bff-dev"
  ignore_source_code_changes = false  # Terraform tracks code changes
}
```

Place your `main.js` in `modules/lambda-node-bff/` directory.

---

## 📋 Inputs

### Core
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `app_name` | Application name (resource prefix) | `string` | - | ✅ |
| `description` | Lambda description | `string` | `"Node.js application..."` | ❌ |
| `existing_lambda_function_name` | Use existing Lambda (migration) | `string` | `null` | ❌ |

### Lambda
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `lambda_handler` | Handler | `string` | `"main.handler"` | ❌ |
| `lambda_runtime` | Runtime | `string` | `"nodejs20.x"` | ❌ |
| `lambda_timeout` | Timeout (seconds) | `number` | `30` | ❌ |
| `lambda_memory_size` | Memory (MB) | `number` | `256` | ❌ |
| `reserved_concurrent_executions` | Concurrency limit | `number` | `null` | ❌ |
| `dead_letter_target_arn` | DLQ ARN (SNS/SQS) | `string` | `null` | ❌ |
| `ignore_source_code_changes` | Ignore code changes | `bool` | `true` | ❌ |
| `environment_variables` | Environment variables | `map(string)` | `{}` | ❌ |
| `log_retention_days` | Lambda log retention | `number` | `14` | ❌ |

### API Gateway
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `cors_allow_origins` | CORS origins | `list(string)` | `["*"]` | ❌ |
| `cors_allow_methods` | CORS methods | `list(string)` | `["GET", "POST", ...]` | ❌ |
| `cors_allow_headers` | CORS headers | `list(string)` | `["*"]` | ❌ |
| `throttling_rate_limit` | Requests/second | `number` | `100` | ❌ |
| `throttling_burst_limit` | Burst limit | `number` | `500` | ❌ |
| `integration_timeout_ms` | Integration timeout | `number` | `29000` | ❌ |

### Logging
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `centralized_api_log_group_name` | Shared API Gateway log group | `string` | `"/aws/apigateway/bff-platform"` | ❌ |
| `api_log_retention_days` | API Gateway log retention | `number` | `30` | ❌ |
| `bff_name` | BFF name (for log filtering) | `string` | `""` | ❌ |
| `environment` | Environment name (for log filtering) | `string` | `""` | ❌ |

### Secrets
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `secrets` | Secrets Manager secrets | `map(object)` | `{}` | ❌ |

---

## 📤 Outputs

| Name | Description |
|------|-------------|
| `lambda_function_name` | Lambda function name |
| `lambda_function_arn` | Lambda ARN |
| `lambda_invoke_arn` | Lambda invoke ARN |
| `lambda_role_arn` | IAM role ARN |
| `lambda_role_name` | IAM role name |
| `lambda_log_group_name` | Lambda log group |
| `api_gateway_id` | API Gateway ID |
| `api_gateway_endpoint` | API Gateway endpoint URL |
| `api_gateway_invoke_url` | API Gateway invoke URL |
| `api_gateway_execution_arn` | API Gateway execution ARN |
| `api_gateway_log_group_name` | API Gateway log group |
| `secrets` | Created secrets (sensitive) |

---

## 🏗️ Architecture

```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │ HTTPS
       ▼
┌─────────────────────────────────┐
│   API Gateway HTTP API          │
│   - Rate Limiting (100 req/s)   │
│   - CORS                         │
│   - Access Logs                  │
└──────┬──────────────────────────┘
       │ AWS_PROXY
       ▼
┌─────────────────────────────────┐
│   Lambda Function               │
│   - Concurrency Limit (100)     │
│   - Secrets via Env Vars        │
│   - DLQ Support                  │
└──────┬──────────────────────────┘
       │
       ▼
┌─────────────────────────────────┐
│   CloudWatch Logs               │
│   - Lambda: /aws/lambda/...     │
│   - API GW: /aws/apigateway/... │
└─────────────────────────────────┘
```

---

## 📦 Resources Created

1. **CloudWatch Log Group** (Lambda): `/aws/lambda/{app_name}_function`
2. **CloudWatch Log Group** (API Gateway): Shared across workspace
3. **IAM Role** (`{app_name}_role`) with:
   - AWSLambdaBasicExecutionRole
   - Secrets Manager permissions (if secrets defined)
4. **Lambda Function** (`{app_name}_function`) - or uses existing
5. **API Gateway HTTP API** (`{app_name}_api`)
6. **Lambda Permission** for API Gateway
7. **Secrets** in AWS Secrets Manager (optional)

---

## 🔧 Migration Guide

### Step 1: Existing Lambda → Add API Gateway

```hcl
module "my_bff" {
  source = "../../modules/lambda-node-bff"

  app_name = "my-bff-prod"
  existing_lambda_function_name = "my-prod-lambda"  # ← Your existing Lambda

  # New features
  throttling_rate_limit = 100
  cors_allow_origins    = ["https://yourdomain.com"]
}
```

### Step 2: Terraform-Managed Code → Separate Pipeline

```hcl
module "my_bff" {
  source = "../../modules/lambda-node-bff"

  app_name = "my-bff-prod"
  ignore_source_code_changes = true  # ← Enable separate pipelines
}
```

Deploy: `terraform apply` (one-time), then use your CI/CD for code updates.

---

## ⚠️ Important Notes

### API Gateway Integration
- Uses **HTTP API (v2)** with Payload Format 2.0
- Lambda must return:
  ```javascript
  {
    statusCode: 200,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ message: 'Hello!' })
  }
  ```

### Security Best Practices
1. **CORS**: Use specific origins in production, not `["*"]`
2. **Secrets**: Never hardcode in `environment_variables`
3. **Rate Limits**: Adjust based on expected traffic
4. **Concurrency**: Set `reserved_concurrent_executions` to prevent runaway costs

---

## 📚 Dependencies

This module depends on:
- `../cloudwatch` - CloudWatch Logs
- `../iam` - IAM Roles
- `../lambda` - Lambda Function
- `../api-gateway` - API Gateway
- `../secrets` - Secrets Manager

---

## 📝 Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

---

## 📄 License

Internal use only.
