variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "service_principal" {
  description = "AWS service principal that can assume this role (e.g., 'lambda.amazonaws.com', 'ec2.amazonaws.com')"
  type        = string
  default     = "lambda.amazonaws.com"
}

variable "additional_principals" {
  description = "Additional principals that can assume this role"
  type = list(object({
    type        = string       # "Service", "AWS", "Federated"
    identifiers = list(string) # List of principal identifiers
  }))
  default = []
}

variable "managed_policy_arns" {
  description = "List of managed policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "attach_lambda_basic_execution_policy" {
  description = "Whether to attach AWSLambdaBasicExecutionRole (for Lambda functions)"
  type        = bool
  default     = false
}

variable "inline_policies" {
  description = "Map of inline policy documents to attach (key = policy name, value = policy JSON)"
  type        = map(string)
  default     = {}
}

variable "secrets_arns" {
  description = "List of Secrets Manager secret ARNs that the role needs access to"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
