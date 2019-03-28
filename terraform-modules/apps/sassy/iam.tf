# Create IAM policy for server
resource "aws_iam_role" "role" {
  name = "sassy-${var.environment}-server"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
         "Service": "ec2.amazonaws.com"
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

resource "aws_iam_instance_profile" "profile" {
  name = "sassy-${var.environment}-server"
  role = "${aws_iam_role.role.name}"
}

# Allow access to s3 bucket
data "terraform_remote_state" "s3" {
  backend = "s3"

  config {
    bucket = "sweetamandas-terraform-state"
    key    = "sassy/${var.environment}/data-stores/s3/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_iam_role_policy" "server_s3" {
  name = "AllowS3Access"
  role = "${aws_iam_role.role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::${data.terraform_remote_state.s3.primary_bucket_id}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::${data.terraform_remote_state.s3.primary_bucket_id}/*"
      ]
    }
  ]
}
EOF
}

# Allow server to read EC2 tags. This is how environment is read by server
resource "aws_iam_role_policy" "server_ec2_tags" {
  name = "AllowEC2DescribeTags"
  role = "${aws_iam_role.role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["ec2:DescribeTags"],
      "Resource": ["*"]
    }
  ]
}
EOF
}

# Allow access to access SSM parameters
resource "aws_iam_role_policy" "server_ssm" {
  name = "AllowSSMParameterAccess"
  role = "${aws_iam_role.role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:DescribeParameters",
        "ssm:GetParameters",
        "ssm:GetParameter",
        "ssm:GetParametersByPath"
      ],
      "Resource": "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/sassy/${var.environment}/*"
    }
  ]
}
EOF
}

# Allow access to github deploy key stored in SSM
resource "aws_iam_role_policy" "server_ssm_github" {
  name = "AllowGithubSSMParameterAccess"
  role = "${aws_iam_role.role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:DescribeParameters",
        "ssm:GetParameter"
      ],
      "Resource": "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/github-ssh-keys/sassy-deploy"
    }
  ]
}
EOF
}

# Allow server to post to cloudwatch logs
resource "aws_iam_role_policy" "server_logs" {
  name = "AllowCloudwatchLogsAccess"
  role = "${aws_iam_role.role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup"
      ],
      "Resource": [
        "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:sassy-${var.environment}-server"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Resource": [
        "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:sassy-${var.environment}-server:log-stream:*"
      ]
    }
  ]
}
EOF
}

# Allow server to send email via SES
data "terraform_remote_state" "ses" {
  backend = "s3"

  config {
    bucket = "sweetamandas-terraform-state"
    key    = "sassy/${var.environment}/ses/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_iam_role_policy" "ses_send" {
  name = "AllowSESSendEmail"
  role = "${aws_iam_role.role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ses:SendEmail",
        "ses:SendRawEmail"
      ],
      "Resource": [
        "*"
      ],
      "Condition":{
        "StringEquals":{
          "ses:FromAddress":"noreply@${data.terraform_remote_state.ses.email_fqdn}"
        }
      }
    }
  ]
}
EOF
}

# Allow server to receive emails via SQS queue
resource "aws_iam_role_policy" "ses_sqs" {
  name = "AllowAccessSESReceiptQueue"
  role = "${aws_iam_role.role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sqs:DeleteMessage",
        "sqs:ReceiveMessage"
      ],
      "Resource": [
        "${data.terraform_remote_state.ses.email_delivery_queue_arn}"
      ]
    }
  ]
}
EOF
}
