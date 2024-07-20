output "bucket_name" {
  description = "ID da bucket"
  value       = aws_s3_bucket.bucket.id
}

output "bucket_domain_name" {
  description = "ID da bucket"
  value       = aws_s3_bucket.bucket.bucket_domain_name
}