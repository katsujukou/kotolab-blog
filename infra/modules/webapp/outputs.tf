output "webapp_s3_bucket_arn" {
  value = aws_s3_bucket.webapp.arn
}

output "cloudfront_distribution_arn" {
  value = aws_cloudfront_distribution.webapp.arn
}