data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "scheduler_lambda"
  output_path = "scheduler_lambda.zip"
}

data "aws_caller_identity" "current" {}

# Create lambda function that keeps dev database running only during business
# hours to save $$$
resource "aws_lambda_function" "scheduler" {
  function_name = "sassy-${var.environment}-mysql-scheduler"

  filename         = "scheduler_lambda.zip"
  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "main.handler"

  runtime = "nodejs8.10"

  role = "${aws_iam_role.scheduler.arn}"

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}

# IAM role which dictates what other AWS services the Lambda function
# may access.
resource "aws_iam_role" "scheduler" {
  name = "sassy-${var.environment}-mysql-scheduler"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}

# Allow scheduler to start and stop mysql dev database
resource "aws_iam_role_policy" "scheduler_rds" {
  name = "sassy-${var.environment}-mysql-scheduler-lambda"
  role = "${aws_iam_role.scheduler.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "rds:StopDBInstance",
          "rds:StartDBInstance"
      ],
      "Resource": "arn:aws:rds:${var.aws_region}:${data.aws_caller_identity.current.account_id}:db:sassy-${var.environment}-mysql"
    }
  ]
}
EOF
}

# Allow scheduler to save logs
resource "aws_iam_role_policy" "scheduler_cloudwatch_logs" {
  name = "sassy-${var.environment}-mysql-scheduler-lambda-logs"
  role = "${aws_iam_role.scheduler.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:logs:${var.aws_region}:*:*"
    }
  ]
}
EOF
}

# Create cloudwatch events to trigger lambda
resource "aws_cloudwatch_event_rule" "start_db" {
  name                = "sassy-${var.environment}-mysql-scheduler-start"
  description         = "Start SASSY ${var.environment} database every weekday morning"
  schedule_expression = "cron(30 11 ? * MON-FRI *)"
}

resource "aws_cloudwatch_event_target" "start_db" {
  rule      = "${aws_cloudwatch_event_rule.start_db.name}"
  target_id = "sassy-${var.environment}-mysql-scheduler-start"
  arn       = "${aws_lambda_function.scheduler.arn}"

  input = <<EOF
{
  "instances": ["sassy-${var.environment}-mysql"],
  "action": "start"
}
EOF
}

resource "aws_cloudwatch_event_rule" "stop_db" {
  name                = "sassy-${var.environment}-mysql-scheduler-stop"
  description         = "Stop SASSY ${var.environment} database every weekday evening"
  schedule_expression = "cron(30 23 ? * MON-FRI *)"
}

resource "aws_cloudwatch_event_target" "stop_db" {
  rule      = "${aws_cloudwatch_event_rule.stop_db.name}"
  target_id = "sassy-${var.environment}-mysql-scheduler-stop"
  arn       = "${aws_lambda_function.scheduler.arn}"

  input = <<EOF
  {
    "instances": ["sassy-${var.environment}-mysql"],
    "action": "stop"
  }
  EOF
}

resource "aws_lambda_permission" "scheduler_start" {
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.scheduler.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.start_db.arn}"
}

resource "aws_lambda_permission" "scheduler_stop" {
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.scheduler.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.stop_db.arn}"
}
