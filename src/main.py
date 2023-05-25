import json
import os
import urllib3
import boto3
###
from botocore.exceptions import ClientError

import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

secret_client = boto3.client("secretsmanager")
webhook_secret_name = os.environ['WEBHOOK_SECRET_NAME']

def get_slack_webhook_url(secret_client, webhook_secret_name: str) -> str:
    """Get Slack Webhook URL from AWS Secrets Manager"""
    if not webhook_secret_name:
        raise exceptions.NoSlackUrlFoundException(
            "No Slack Webhook URL Secret Name provided. Check config file."
        )

    logger.debug(
        "Looking up Slack Webhook URL in Secrets Manager at %s", webhook_secret_name
    )
    try:
        secret_string = secret_client.get_secret_value(SecretId=webhook_secret_name)[
            "SecretString"
        ]
        return secret_string
    except json.decoder.JSONDecodeError as err:
        raise exceptions.InvalidSecretValueException(
            "Slack Webhook URL secret value is not valid JSON, %s", err
        )
    except KeyError as err:
        raise exceptions.InvalidSecretValueException(
            "Slack Webhook URL secret value does not have a key named `url`, %s", err
        )
    except ClientError as err:
        if err.response["Error"]["Code"] == "ResourceNotFoundException":
            raise exceptions.NoSlackUrlFoundException(
                "Slack Webhook URL not found in Secrets Manager at %s"
                % webhook_secret_name
            )
        raise err


def lambda_handler(event, context):
    slack_webhook = get_slack_webhook_url(secret_client, webhook_secret_name)
    logger.info("Found slack webhook URL: %s", slack_webhook)

    message_body = event['detail']
    logger.info(message_body)

    #variables for slack message
    subject = "AWS CloudWatch Notification"
    alarm_name = message_body['alarmName']
    old_state = message_body['previousState']['value']
    new_state = message_body['state']['value']
    description = message_body['configuration']['description']
    reason = message_body['state']['reason']
    region = event['region']

    slack_message = {
    #'webhook_url': slack_webhook,
    "text": "*" + subject + "*",
    "attachments": [
        {
            "color": "#ff0000",
            "fields": [
                {"title": "Alarm Name", "value": alarm_name, "short": True},
                {"title": "Alarm Description", "value": description, "short": False},
                {"title": "Trigger","value": reason,"short": False,},
                {"title": "Old State", "value": old_state, "short": True},
                {"title": "Current State", "value": new_state, "short": True},
                {
                    "title": "Link to Alarm",
                    "value": "https://console.aws.amazon.com/cloudwatch/home?region="
                    + region
                    + "#alarmsV2:alarm/"
                    + alarm_name,
                    "short": False,
                },
            ],
        }
    ],
    }
    
    http = urllib3.PoolManager()
    response = http.request(
        'POST',
        slack_webhook,
        headers={'Content-Type': 'application/json'},
        body=json.dumps(slack_message)
    )
    if response.status == 200:
        return {
            'statusCode': 200,
            'body': 'Slack notification sent successfully!'
        }
    else:
        return {
            'statusCode': response.status,
            'body': logger.info(response.data.decode('utf-8'))
        }