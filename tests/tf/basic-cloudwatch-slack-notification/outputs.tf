output "secret_arn" {
  value       = module.cloudwatch-slack-notification.secret_arn
  description = "The ARN of the secret that stores the slack webhook"
}

