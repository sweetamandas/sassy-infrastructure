output "primary_bucket_id" {
  description = "Name of environment's primary s3 bucket"
  value       = "${aws_s3_bucket.primary.id}"
}
