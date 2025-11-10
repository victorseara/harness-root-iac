variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "description" {
  description = "Description of the API Gateway"
  type        = string
  default     = ""
}

variable "lambda_arn" {
  description = "ARN of the Lambda function to integrate with (not invoke_arn)"
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

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
