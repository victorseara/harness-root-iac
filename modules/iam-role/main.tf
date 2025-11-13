# Generic IAM role with configurable trust policy
resource "aws_iam_role" "this" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [{
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = var.service_principal
        }
      }],
      [for principal in var.additional_principals : {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          (principal.type) = principal.identifiers
        }
      }]
    )
  })

  tags = var.tags
}

# Managed policy attachments
resource "aws_iam_role_policy_attachment" "managed_policies" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

# Optional Lambda basic execution policy (backward compatible)
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  count = var.attach_lambda_basic_execution_policy ? 1 : 0

  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Inline policies
resource "aws_iam_role_policy" "inline_policies" {
  for_each = var.inline_policies

  name   = each.key
  role   = aws_iam_role.this.id
  policy = each.value
}

# Secrets Manager access policy (backward compatible)
resource "aws_iam_role_policy" "secrets_policy" {
  count = length(var.secrets_arns) > 0 ? 1 : 0
  name  = "${var.role_name}-secrets-policy"
  role  = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = var.secrets_arns
      }
    ]
  })
}
