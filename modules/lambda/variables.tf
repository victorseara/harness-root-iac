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
  description = "Lambda function handler (e.g., 'index.handler', 'main.lambda_handler')"
  type        = string
  default     = "main.handler"
}

variable "runtime" {
  description = "Lambda runtime (e.g., 'nodejs20.x', 'python3.12', 'java17', 'go1.x')"
  type        = string
  default     = "nodejs20.x"
}

variable "architectures" {
  description = "Instruction set architecture for Lambda function. Valid values: ['x86_64'] or ['arm64']"
  type        = list(string)
  default     = ["x86_64"]
  validation {
    condition     = alltrue([for arch in var.architectures : contains(["x86_64", "arm64"], arch)])
    error_message = "Architectures must be either 'x86_64' or 'arm64'."
  }
}

variable "layers" {
  description = "List of Lambda Layer Version ARNs to attach"
  type        = list(string)
  default     = []
}

variable "ephemeral_storage_size" {
  description = "Amount of ephemeral storage (/tmp) in MB (512-10240)"
  type        = number
  default     = 512
  validation {
    condition     = var.ephemeral_storage_size >= 512 && var.ephemeral_storage_size <= 10240
    error_message = "Ephemeral storage must be between 512 and 10240 MB."
  }
}

variable "publish" {
  description = "Whether to publish creation/change as new Lambda Function Version"
  type        = bool
  default     = false
}

variable "timeout" {
  description = "Function timeout in seconds"
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "Memory size in MB"
  type        = number
  default     = 256
}

variable "filename" {
  description = "Path to the Lambda deployment package (zip file)"
  type        = string
}

variable "role_arn" {
  description = "ARN of the IAM role for the Lambda function"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "reserved_concurrent_executions" {
  description = "Amount of reserved concurrent executions for this lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations"
  type        = number
  default     = null
}

variable "dead_letter_target_arn" {
  description = "ARN of an SNS topic or SQS queue to notify when an invocation fails"
  type        = string
  default     = null
}

variable "ignore_source_code_changes" {
  description = "Whether to ignore source code changes (true for separate deployment pipelines, false to track in Terraform)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
