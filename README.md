### Cloudwatch Slack Notifications

This module deploys resources needed to send cloudwatch alarm information to slack and other destinations. By default, it picks up events for all Alarms in an "Alarm" state and send those events to the targets.
### Basic Setup

- Create the AWS resources using the module as shown below.
```hcl
module "cloudwatch-slack-notifications" {
  source   = "git::https://gitlab-tools.swacorp.com/cpe/terraform-modules/cloudwatch-slack-notifications.git?ref={latest tag version}"
  name                         = "test-cloudwatch-alarm-slack-notification"
}
```
- In the management console, navigate to the secrets manager service.
- Find the secret created by the module (```${var.name}/cloudwatch_slack_notifications/webhook_url```), and replace the value with the slack webhook.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lambda"></a> [lambda](#module\_lambda) | git::https://gitlab-tools.swacorp.com/cpe/terraform-modules/aws-lambda.git | v1.0.4 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.cloudwatch_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.cloudwatch_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_policy.lambda_exec_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.lambda_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_permission.event_bridge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_secretsmanager_secret.webhook_url](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.lambda_exec_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_kms_key.secret_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the cloudwatch-slack integration | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | `"us-east-1"` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Indentifier of the function runtime | `string` | `"python3.9"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to attach to the resources created | `map(string)` | `{}` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Time the lambda function has to run | `number` | `60` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | AWS arn of lambda function |
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | Name of lambda function |
| <a name="output_qualified_arn"></a> [qualified\_arn](#output\_qualified\_arn) | AWS Qualified arn of lambda function |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | ARN of the lambda execution role |
<!-- END_TF_DOCS -->