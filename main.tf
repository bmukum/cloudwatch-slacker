data "aws_caller_identity" "current" {}

data "aws_kms_key" "secret_key" {
  key_id = "alias/swa_${data.aws_caller_identity.current.account_id}_kms"
}

// The slack webook URL would be stored in secrets manager
resource "aws_secretsmanager_secret" "webhook_url" {
  #checkov:skip=CKV2_AWS_57: cannot support autorotation
  name                    = "${var.name}/cloudwatch_slack_notifications/webhook_url"
  description             = "Slack webhook URL to send notifications for ${var.name} cloudwatch alarms."
  kms_key_id              = data.aws_kms_key.secret_key.arn
  recovery_window_in_days = var.secret_recovery_window_in_days

}
//CW event rule to capture cloudwatch alarm info
resource "aws_cloudwatch_event_rule" "cloudwatch_lambda" {
  name        = var.name
  description = "This rule filters cloudwatch alarm info"

  event_pattern = jsonencode({
    source      = ["aws.cloudwatch"]
    detail-type = ["CloudWatch Alarm State Change"]
    detail = {
      state = {
        value = ["ALARM"]
      }
    }
  })
}

//CW event target to forward alarm information to the lambda function
resource "aws_cloudwatch_event_target" "cloudwatch_lambda" {
  rule      = aws_cloudwatch_event_rule.cloudwatch_lambda.name
  target_id = "SendToLambda"
  arn       = module.lambda.arn
}

//permissions for event bridge to trigger the lambda function
resource "aws_lambda_permission" "event_bridge" {
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cloudwatch_lambda.arn
}

//lambda module
module "lambda" {
  source                     = "git::https://gitlab-tools.swacorp.com/cpe/terraform-modules/aws-lambda.git?ref=v1.0.4"
  swa_name                   = var.name
  account_id                 = data.aws_caller_identity.current.account_id
  region                     = var.region
  runtime                    = var.runtime
  description                = "Lambda function to send Cloudwatch alarm notifications to slack."
  tags                       = var.tags
  function_name              = var.name
  handler                    = "main.lambda_handler"
  deployment_package         = "${path.module}/src/lambda.zip"
  lambda_execution_role_name = aws_iam_role.lambda_role.name
  lambda_execution_role_arn  = aws_iam_role.lambda_role.arn
  timeout                    = var.timeout

  environment = {
    WEBHOOK_SECRET_NAME = "${var.name}/cloudwatch_slack_notifications/webhook_url"
  }
}

//lambda assume role
resource "aws_iam_role" "lambda_role" {
  name = "${var.name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

//lambda execution permissions document
data "aws_iam_policy_document" "lambda_exec_policy" {

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "logs:PutLogEvents",
      "logs:CreateLogGroup",
      "logs:CreateLogStream"
    ]
    resources = [aws_secretsmanager_secret.webhook_url.arn]
  }
}
//lambda policy
resource "aws_iam_policy" "lambda_exec_policy" {
  name   = "${var.name}-lambda"
  policy = data.aws_iam_policy_document.lambda_exec_policy.json

}

//policy attachement
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_exec_policy.arn
  role       = aws_iam_role.lambda_role.name
}


