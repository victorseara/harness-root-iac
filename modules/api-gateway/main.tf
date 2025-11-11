# Create CloudWatch log group for API Gateway with proper naming
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.api_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# Create API Gateway
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

# Create Lambda integration
resource "aws_apigatewayv2_integration" "lambda" {
  api_id = aws_apigatewayv2_api.this.id

  integration_type   = "AWS_PROXY"
  integration_uri    = var.lambda_arn
  integration_method = "POST"

  payload_format_version = "2.0"
  timeout_milliseconds   = var.integration_timeout_ms
}

# Create default route
resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# Create stage with access logging
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
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

  # Wait for externally defined resources to be ready.
  # This is used to pass in the dependency on aws_api_gateway_account.
  depends_on = concat([
    aws_apigatewayv2_route.default,
  ], var.stage_depends_on)
}
