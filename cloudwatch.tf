resource "aws_cloudwatch_event_rule" "auto_shutdown" {
  name        = "auto-shutdown-ec2"
  description = "Power off EC2s at the end of the day"

  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "auto_shutdown_lambda" {
  target_id = "${aws_lambda_function.stop_ec2_instances.handler}"
  rule      = "${aws_cloudwatch_event_rule.auto_shutdown.name}"
  arn       = "${aws_lambda_function.stop_ec2_instances.arn}"
}
