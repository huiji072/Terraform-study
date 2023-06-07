resource "aws_sns_topic" "sns-topic-test-app" {
  name = "${local.prefix}-${local.suffix}"
}

# resource "aws_sns_topic_subscription" "email_subscription" {
#   topic_arn = aws_sns_topic.finexblock-btc-engine-dev-sns.arn
#   protocol  = "email"
#   endpoint  = "huijikim00@thefuturecompany.info"
# }

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm" {
  alarm_name          = "${local.prefix}-${local.suffix}-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "70"
  alarm_description   = "Trigger an alarm when CPU Utilization is over 70% for instance"
  alarm_actions       = [aws_sns_topic.sns-topic-test-app.arn]
  dimensions = {
    InstanceId = aws_instance.ec2-test-app.id
  }
}   

resource "aws_cloudwatch_log_group" "cw-log-group-test-app" {
  name = "${local.prefix}-${local.suffix}"
}

resource "aws_cloudwatch_log_stream" "cw-log-stream-test-app" {
  name            = "${local.prefix}-${local.suffix}"
  log_group_name  = aws_cloudwatch_log_group.cw-log-group-test-app.name
}