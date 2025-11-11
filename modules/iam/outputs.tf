output "role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.lambda_role.arn
}

output "role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.lambda_role.name
}

output "role_id" {
  description = "ID of the IAM role"
  value       = aws_iam_role.lambda_role.id
}

output "policy_attachment_id" {
  description = "ID of the policy attachment (for dependency management)"
  value       = aws_iam_role_policy_attachment.lambda_logs.id
}
