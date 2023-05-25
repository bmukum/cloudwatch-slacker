package main

import (
	"fmt"
	"testing"

	"github.com/stretchr/testify/assert"

	"github.com/gruntwork-io/terratest/modules/terraform"
	// "github.com/gruntwork-io/terratest/modules/aws"
	// "github.com/aws/aws-sdk-go/aws/session"
	// "github.com/aws/aws-sdk-go/service/secretsmanager"
	// "github.com/stretchr/testify/assert"
)

var cloudwatchSlackTests = []struct {
	name                       string
	region                     string
	terraformDir               string
	secretRecoveryWindowInDays int
	skip                       bool
}{
	{
		name:         "basic",
		region:       "us-east-1",
		terraformDir: "./tf/basic-cloudwatch-slack-notification",
		skip:         false,
	},
}

// Test func
func TestCloudwatchSlack(t *testing.T) {

	for _, tt := range cloudwatchSlackTests {
		if tt.skip {
			fmt.Printf("skipping: %s\n", tt.name)
		} else {
			t.Run(tt.name, func(t *testing.T) {

				terraformVars := map[string]interface{}{
					"name": fmt.Sprintf("cw_slack_notif_test_%s", tt.name),
				}

				terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
					TerraformDir: tt.terraformDir,
					Vars:         terraformVars,
					Upgrade:      false,
				})
				// defer destruction of resources
				defer terraform.Destroy(t, terraformOptions)

				// init and apply terraform
				_, err := terraform.InitAndApplyE(t, terraformOptions)
				if err != nil {
					t.Errorf("%s", err)
				}

				secret_arn := terraform.Output(t, terraformOptions, "secret_arn")
				assert.NotEmpty(t, secret_arn)

			})
		}
	}
}
