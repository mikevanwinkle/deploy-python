resource "aws_api_gateway_rest_api" "project_api" {
  name        = "${var.project}_api"
  description = "Terraform Serverless Application ${var.project}_api"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.project_api.id
  parent_id   = aws_api_gateway_rest_api.project_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.project_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.project_api.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.project_lambda.invoke_arn
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.project_api.id
  resource_id   = aws_api_gateway_rest_api.project_api.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.project_api.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.project_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "project_deploy" {
  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.lambda_root,
  ]

  rest_api_id = aws_api_gateway_rest_api.project_api.id
}


resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.project_deploy.id
  rest_api_id   = aws_api_gateway_rest_api.project_api.id
  stage_name    = var.stage
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.project_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.project_api.execution_arn}/*/*"
}

resource "aws_acm_certificate" "project_cert" {
  provider = aws.us-east-1

  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "project_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.project_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name    = each.value.name
  type    = each.value.type
  zone_id = data.aws_route53_zone.account_root_hosted_zone.zone_id
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "validation" {
  provider = aws.us-east-1

  certificate_arn         = aws_acm_certificate.project_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.project_cert_validation : record.fqdn]
}

resource "aws_route53_record" "project_dns" {
  name    = var.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.account_root_hosted_zone.id

  alias {
    evaluate_target_health = true
    name                   = aws_cloudfront_distribution.project.domain_name
    zone_id                = aws_cloudfront_distribution.project.hosted_zone_id
  }
}
