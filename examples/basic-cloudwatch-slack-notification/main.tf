module "test_sqs" {
#   source   = "git::https://gitlab-tools.swacorp.com/cpe/terraform-modules/cloudwatch-slack-notifications.git?ref={latest tag version}"
  source   = "../.."
  name     = "test-cloudwatch-alarm-slack-notification"
}
