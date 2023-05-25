variable "name" {
  type        = string
  description = "Name of the cloudwatch-slack integration"
}

variable "runtime" {
  type        = string
  description = "Indentifier of the function runtime"
  default     = "python3.9"
}

variable "timeout" {
  type        = number
  description = "Time the lambda function has to run"
  default     = 60
}

variable "tags" {
  type        = map(string)
  description = "Tags to attach to the resources created"
  default     = {}
}
variable "region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
}

variable "secret_recovery_window_in_days" {
  type        = number
  description = "Number of days that AWS Secrets Manager waits before it can delete the secret. This value can be 0 to force deletion without recovery or range from 7 to 30 days"
  default     = 7
}
