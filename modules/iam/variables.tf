variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "custom_policy_json" {
  description = "Custom IAM policy JSON (if not provided, uses default logging policy)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
