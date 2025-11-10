variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "description" {
  description = "Description of the Lambda function"
  type        = string
  default     = ""
}

variable "handler" {
  description = "Lambda function handler"
  type        = string
  default     = "index.handler"
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "nodejs20.x"
}

variable "timeout" {
  description = "Function timeout in seconds"
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "Memory size in MB"
  type        = number
  default     = 128
}

variable "filename" {
  description = "Path to the Lambda deployment package (zip file)"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "role_name" {
  description = "Name of the IAM role (defaults to {function_name}-role)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "custom_policy_json" {
  description = "Custom IAM policy JSON for the Lambda function"
  type        = string
  default     = null
}

variable "create_api_gateway_permission" {
  description = "Whether to create API Gateway invoke permission"
  type        = bool
  default     = false
}

variable "api_gateway_execution_arn" {
  description = "ARN of the API Gateway execution (required if create_api_gateway_permission is true)"
  type        = string
  default     = null
}

variable "ignore_source_code_hash" {
  description = "Whether to ignore changes to source code hash (set to true when deployments are handled outside Terraform)"
  type        = bool
  default     = true
}
