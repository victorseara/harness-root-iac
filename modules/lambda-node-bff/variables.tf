variable "app_name" {
  description = "Name of the application (used as prefix for resources)"
  type        = string
}

variable "description" {
  description = "Description of the Lambda function"
  type        = string
  default     = "Node.js application running on Lambda"
}

variable "lambda_handler" {
  description = "Lambda function handler"
  type        = string
  default     = "main.handler"
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "nodejs20.x"
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 256
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "api_gateway_description" {
  description = "Description of the API Gateway"
  type        = string
  default     = ""
}

variable "cors_allow_origins" {
  description = "CORS allowed origins"
  type        = list(string)
  default     = ["*"]
}

variable "cors_allow_methods" {
  description = "CORS allowed methods"
  type        = list(string)
  default     = ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"]
}

variable "cors_allow_headers" {
  description = "CORS allowed headers"
  type        = list(string)
  default     = ["*"]
}

variable "cors_expose_headers" {
  description = "CORS expose headers"
  type        = list(string)
  default     = []
}

variable "cors_max_age" {
  description = "CORS max age in seconds"
  type        = number
  default     = 600
}

variable "cors_allow_credentials" {
  description = "CORS allow credentials"
  type        = bool
  default     = false
}

variable "integration_timeout_ms" {
  description = "API Gateway integration timeout in milliseconds (max 30000)"
  type        = number
  default     = 29000
}

# Security and Performance
variable "reserved_concurrent_executions" {
  description = "Reserved concurrent executions for Lambda (prevents resource exhaustion)"
  type        = number
  default     = null
}

variable "dead_letter_target_arn" {
  description = "ARN of DLQ (SNS or SQS) for failed Lambda invocations"
  type        = string
  default     = null
}

variable "ignore_source_code_changes" {
  description = "Ignore source code changes in Terraform (true for separate deployment pipelines)"
  type        = bool
  default     = true
}

variable "throttling_burst_limit" {
  description = "API Gateway throttling burst limit (requests)"
  type        = number
  default     = 500
}

variable "throttling_rate_limit" {
  description = "API Gateway throttling rate limit (requests per second)"
  type        = number
  default     = 100
}

# Secrets Management
variable "secrets" {
  description = "Map of secrets to create in AWS Secrets Manager"
  type = map(object({
    description             = string
    value                   = string
    recovery_window_in_days = number
  }))
  default = {}
  # Note: Cannot be marked as sensitive because it's used in for_each
  # The secret values themselves are still protected in Secrets Manager
}

# Centralized Logging
variable "centralized_api_log_group_arn" {
  description = "CloudWatch log group ARN for API Gateway logs (shared across BFFs in workspace)"
  type        = string
  default     = null
}

variable "bff_name" {
  description = "Name of the BFF for log filtering (defaults to app_name)"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment name for log filtering (e.g., 'dev', 'prod')"
  type        = string
  default     = ""
}

# Migration Support
variable "existing_lambda_function_name" {
  description = "Name of existing Lambda function to use (for migrating existing apps). If provided, skips Lambda creation and uses existing function."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
