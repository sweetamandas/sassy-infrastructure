output "certificate_arn" {
  description = "ARN of TLS certificate that was created"
  value       = "${aws_acm_certificate_validation.cert.certificate_arn}"
}
