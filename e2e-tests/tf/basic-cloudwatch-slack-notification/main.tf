module "cloudwatch-slack-notification" {
  source                         = "../../../"
  name                           = var.name
  secret_recovery_window_in_days = var.secret_recovery_window_in_days
}
