resource "aws_cloudwatch_log_group" "log_group" {
  name              = "sassy-${var.environment}-server"
  retention_in_days = 30

  tags = {
    Environment = "${var.environment}"
    Application = "sassy"
  }
}
