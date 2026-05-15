output "aws_s3_bucket_name" {
  value = aws_s3_bucket.firstbucket
}
output "aws_cloudfront_domain_name" {
    value = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "cloudfont_id" {
  value = aws_cloudfront_distribution.s3_distribution.id
}
