output "email_delivery_queue_arn" {
  description = "ARN of SQS queue that received emails are posted to"
  value       = "${aws_sqs_queue.email_receipt.arn}"
}

output "email_fqdn" {
  description = "FQDN that email will be sent from"
  value       = "${local.fqdn}"
}
