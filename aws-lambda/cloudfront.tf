resource "aws_cloudfront_origin_access_control" "project" {
  name                              = "${var.project}-${var.env} OAC"
  description                       = "${var.project}-${var.env} OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "project" {
  comment         = "${var.project}-${var.env}"
  aliases         = [var.domain_name]
  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_100"

  origin {
    domain_name              = aws_s3_bucket.project_static.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.project.id
    origin_id                = aws_s3_bucket.project_static.bucket_regional_domain_name
  }

  origin {
    domain_name = "${aws_api_gateway_rest_api.project_api.id}.execute-api.${var.region}.amazonaws.com"
    origin_id   = "${aws_api_gateway_rest_api.project_api.id}.execute-api.${var.region}.amazonaws.com"
    origin_path = "/api"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {

    allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods           = ["GET", "HEAD"]
    viewer_protocol_policy   = "redirect-to-https"
    target_origin_id         = "${aws_api_gateway_rest_api.project_api.id}.execute-api.${var.region}.amazonaws.com"
    cache_policy_id          = data.aws_cloudfront_cache_policy.managed_caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.managed_all_viewer_except_host_header.id
    min_ttl                  = 0
    default_ttl              = 0
    max_ttl                  = 0
    compress                 = false

  }

  ordered_cache_behavior {
    path_pattern           = "/static/*"
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching_optimized.id
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.project_static.bucket_regional_domain_name
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.project_cert.arn
    minimum_protocol_version = "TLSv1"
    ssl_support_method       = "sni-only"
  }

  provisioner "local-exec" {
    command = "aws cloudfront create-invalidation --distribution-id ${self.id} --paths '/*'"
  }
}
