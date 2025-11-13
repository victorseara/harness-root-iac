variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "description" {
  description = "Description of the API Gateway"
  type        = string
  default     = ""
}

variable "lambda_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  type        = string
}

variable "integration_timeout_ms" {
  description = "Integration timeout in milliseconds (50-30000)"
  type        = number
  default     = 30000
}

variable "cors_allow_origins" {
  description = "CORS allowed origins"
  type        = list(string)
  default     = ["*"]
}

variable "cors_allow_methods" {
  description = "CORS allowed methods"
  type        = list(string)
  default     = ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS", "HEAD"]
}

variable "cors_allow_headers" {
  description = "CORS allowed headers"
  type        = list(string)
  default     = ["*"]
}

variable "cors_expose_headers" {
  description = "CORS exposed headers"
  type        = list(string)
  default     = []
}

variable "cors_max_age" {
  description = "CORS max age in seconds"
  type        = number
  default     = 300
}

variable "cors_allow_credentials" {
  description = "Whether to allow credentials in CORS"
  type        = bool
  default     = false
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

variable "access_log_destination_arn" {
  description = "ARN of CloudWatch Logs log group for API Gateway access logs"
  type        = string
  default     = null
}

variable "access_log_format" {
  description = "Custom access log format (JSON encoded string). If null, uses default format."
  type        = string
  default     = null
}

variable "additional_log_fields" {
  description = "Additional custom fields to add to access logs (merged with standard fields)"
  type        = map(string)
  default     = {}
}

variable "stage_name" {
  description = "Name of the API Gateway stage"
  type        = string
  default     = "$default"
}

variable "auto_deploy" {
  description = "Whether to automatically deploy changes"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
