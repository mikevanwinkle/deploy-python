output "api_gateway_invoke_url" {
  value = aws_api_gateway_stage.api_stage.invoke_url
}

output "s3_web_bucket" {
  value = aws_s3_bucket.project_static.bucket
}

output "cloudfront_distro" {
  value = aws_cloudfront_distribution.project.id
}
