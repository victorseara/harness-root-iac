# API Gateway HTTP API
resource "aws_apigatewayv2_api" "this" {
  name          = var.api_name
  description   = var.description
  protocol_type = "HTTP"

  cors_configuration {
    allow_headers     = var.cors_allow_headers
    allow_methods     = var.cors_allow_methods
    allow_origins     = var.cors_allow_origins
    expose_headers    = var.cors_expose_headers
    max_age           = var.cors_max_age
    allow_credentials = var.cors_allow_credentials
  }

  tags = var.tags
}

# Lambda integration
resource "aws_apigatewayv2_integration" "lambda" {
  api_id = aws_apigatewayv2_api.this.id

  integration_type   = "AWS_PROXY"
  integration_uri    = var.lambda_invoke_arn
  integration_method = "POST"

  payload_format_version = "2.0"
  timeout_milliseconds   = var.integration_timeout_ms
}

# Default route
resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# Local values for log format
locals {
  # Default log format with standard fields
  default_log_format = {
    requestId               = "$context.requestId"
    extendedRequestId       = "$context.extendedRequestId"
    ip                      = "$context.identity.sourceIp"
    caller                  = "$context.identity.caller"
    user                    = "$context.identity.user"
    requestTime             = "$context.requestTime"
    httpMethod              = "$context.httpMethod"
    resourcePath            = "$context.resourcePath"
    routeKey                = "$context.routeKey"
    status                  = "$context.status"
    protocol                = "$context.protocol"
    responseLength          = "$context.responseLength"
    integrationErrorMessage = "$context.integrationErrorMessage"
    integrationStatus       = "$context.integrationStatus"
    errorMessage            = "$context.error.message"
    errorMessageString      = "$context.error.messageString"
  }

  # Merge additional fields into default format
  log_format_with_custom_fields = length(var.additional_log_fields) > 0 ? merge(
    local.default_log_format,
    var.additional_log_fields
  ) : local.default_log_format

  # Final log format (custom overrides everything)
  final_log_format = var.access_log_format != null ? var.access_log_format : jsonencode(local.log_format_with_custom_fields)
}

# Stage with access logging and throttling
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = var.stage_name
  auto_deploy = var.auto_deploy

  # Rate limiting and throttling
  default_route_settings {
    throttling_burst_limit = var.throttling_burst_limit
    throttling_rate_limit  = var.throttling_rate_limit
  }

  # Access logging configuration
  dynamic "access_log_settings" {
    for_each = var.access_log_destination_arn != null ? [1] : []
    content {
      destination_arn = var.access_log_destination_arn
      format          = local.final_log_format
    }
  }

  tags = var.tags
}
