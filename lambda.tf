resource "aws_lambda_function" "stop_ec2_instances" {
  filename         = ".lambda_stop_ec2_payload.zip"
  function_name    = "stop_ec2_instances"
  description      = "Shuts down unused EC2 instances."
  role             = "${aws_iam_role.lambda_start_stop_ec2.arn}"
  handler          = "stop_ec2.lambda_handler"
  source_code_hash = "${base64sha256(file(".lambda_stop_ec2_payload.zip"))}"
  runtime          = "python2.7"
  timeout          = 180
}

resource "aws_lambda_permission" "allow_execution_from_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.stop_ec2_instances.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.auto_shutdown.arn}"
}
