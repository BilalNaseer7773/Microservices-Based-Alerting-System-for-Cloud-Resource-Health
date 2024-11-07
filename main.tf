provider "aws" {
  region = "us-east-1"
}

# SNS Topic for alerts
resource "aws_sns_topic" "alerts_topic" {
  name = "cloud_monitoring_alerts"
}

# CloudWatch Alarm to monitor CPU utilization
resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "HighCPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This alarm triggers when CPU utilization is greater than 80% for 10 minutes."
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.alerts_topic.arn]

  dimensions = {
    InstanceId = "your-instance-id"
  }
}

# Lambda function for custom alerts
resource "aws_lambda_function" "alert_function" {
  function_name = "CloudResourceAlertFunction"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  filename      = "lambda_function.zip"
}
