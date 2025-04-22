resource "aws_lambda_layer_version" "lambda_layer" {
  filename            = "layer.zip"
  layer_name          = "${var.project}-layer"
  source_code_hash    = filebase64sha256("layer.zip")
  compatible_runtimes = ["python3.13"]
}


resource "aws_cloudwatch_log_group" "api_logstream" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}


resource "aws_lambda_function" "project_lambda" {
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_role.arn
  handler          = "main.handler"
  runtime          = "python3.13"
  architectures    = ["x86_64"]
  filename         = "function.zip"
  depends_on       = [resource.aws_cloudwatch_log_group.api_logstream]
  source_code_hash = filebase64sha256("function.zip")
  memory_size      = 512
  layers           = [aws_lambda_layer_version.lambda_layer.arn]

  # Advanced logging controls (optional)
  logging_config {
    log_format = "Text"
  }

  environment {
    variables = {
      DB_TABLE_NAME = "${var.project}-${var.env}"
    }
  }
}
