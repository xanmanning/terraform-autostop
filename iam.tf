data "aws_iam_policy_document" "lambda_start_stop_ec2_doc" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }

  statement {
    actions = [
      "ec2:Describe*",
      "ec2:Start*",
      "ec2:Stop*",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "lambda_start_stop_ec2_policy" {
  name   = "lambda_start_stop_ec2_policy"
  path   = "/"
  policy = "${data.aws_iam_policy_document.lambda_start_stop_ec2_doc.json}"
}

resource "aws_iam_role" "lambda_start_stop_ec2" {
  name = "lambda_start_stop_ec2"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Sid": ""
    }]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_stop_start_ec2" {
  role       = "${aws_iam_role.lambda_start_stop_ec2.name}"
  policy_arn = "${aws_iam_policy.lambda_start_stop_ec2_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "basic-exec-role" {
  role       = "${aws_iam_role.lambda_start_stop_ec2.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
