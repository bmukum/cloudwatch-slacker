data "aws_caller_identity" "current" {}
data "aws_region" "region" {}

resource "aws_secretsmanager_secret" "webhook_url" {
  name                    = "${var.name}/cloudwatch_slack_notifications/webhook_url"
  description             = "Slack webhook URL to send notifications for ${var.name} cloudwatch alarms."
  recovery_window_in_days = var.secret_recovery_window_in_days

}

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

resource "aws_cloudwatch_event_target" "cloudwatch_lambda" {
  rule      = aws_cloudwatch_event_rule.cloudwatch_lambda.name
  target_id = "SendToLambda"
  arn       = module.lambda.arn
}

resource "aws_lambda_permission" "event_bridge" {
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cloudwatch_lambda.arn
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/src/main.py"
  output_path = "${path.module}/deployment-package/lambda.zip"
}

resource "aws_lambda_function" "function" {
  filename      = "${path.module}/deployment-package/lambda.zip"
  function_name = var.name
  role          = aws_iam_role.lambda_role.arn
  handler       = "main.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.10"
}

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

resource "aws_iam_policy" "lambda_exec_policy" {
  name   = "${var.name}-lambda"
  policy = data.aws_iam_policy_document.lambda_exec_policy.json

}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_exec_policy.arn
  role       = aws_iam_role.lambda_role.name
}


