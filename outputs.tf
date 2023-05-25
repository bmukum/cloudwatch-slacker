output "function_name" {
  description = "Name of lambda function"
  value       = module.lambda.function_name
}

output "function_arn" {
  description = "AWS arn of lambda function"
  value       = module.lambda.arn
}

output "qualified_arn" {
  description = "AWS Qualified arn of lambda function"
  value       = module.lambda.qualified_arn
}

output "role_arn" {
  value       = aws_iam_role.lambda_role.arn
  description = "ARN of the lambda execution role"
}

output "secret_arn" {
  value       = aws_secretsmanager_secret.webhook_url.arn
  description = "The ARN of the secret that stores the slack webhook"
}

