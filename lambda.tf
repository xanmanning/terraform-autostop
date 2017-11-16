resource "aws_lambda_function" "stop_ec2_instances" {
  filename         = ".lambda_stop_ec2_payload.zip"
  function_name    = "stop_ec2_instances"
  description      = "Shuts down unused EC2 instances."
  role             = "${aws_iam_role.lambda_start_stop_ec2.arn}"
  handler          = "stop_ec2"
  source_code_hash = "${base64sha256(file(".lambda_stop_ec2_payload.zip"))}"
  runtime          = "python2.7"
  timeout          = 10
}

resource "aws_lambda_function" "start_ec2_instances" {
  filename         = ".lambda_start_ec2_payload.zip"
  function_name    = "start_ec2_instances"
  description      = "Shuts down unused EC2 instances."
  role             = "${aws_iam_role.lambda_start_stop_ec2.arn}"
  handler          = "start_ec2"
  source_code_hash = "${base64sha256(file(".lambda_start_ec2_payload.zip"))}"
  runtime          = "python2.7"
  timeout          = 10
}
