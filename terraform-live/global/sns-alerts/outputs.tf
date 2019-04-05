output "system_alert_topic_arn" {
  description = "ARN of system alert topic"
  value       = "${aws_sns_topic.alerts.arn}"
}
