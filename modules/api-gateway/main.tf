module "api_gateway" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "~> 5.0"

  name          = var.api_name
  description   = var.description
  protocol_type = "HTTP"

  # Disable custom domain and certificate creation
  create_domain_name    = false
  create_certificate    = false
  create_domain_records = false

  # CORS configuration
  cors_configuration = {
    allow_headers     = var.cors_allow_headers
    allow_methods     = var.cors_allow_methods
    allow_origins     = var.cors_allow_origins
    expose_headers    = var.cors_expose_headers
    max_age           = var.cors_max_age
    allow_credentials = var.cors_allow_credentials
  }

  # Routes with Lambda integration (v5.x uses routes instead of integrations)
  routes = {
    "$default" = {
      integration = {
        uri                    = var.lambda_arn
        type                   = "AWS_PROXY"
        payload_format_version = "2.0"
        timeout_milliseconds   = var.integration_timeout_ms
      }
    }
  }

  # Stage access logging (v5.x syntax)
  stage_access_log_settings = {
    create_log_group            = true
    log_group_retention_in_days = var.log_retention_days
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }

  tags = var.tags
}
