provider "aws" {
  region = var.region
}

# primary role for code execution (using aws lambda) and followed by its attachment 
resource "aws_iam_role" "lambda_exec" {
  name = "url_shortener_lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = "LambdaBasicExecutionPolicy"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_policy_attachment" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# IAM access policy and its attachment for DynamoDB
resource "aws_iam_policy" "lambda_dynamodb_access_policy" {
  name = "url_shortener_lambda_dynamodb_access_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem"
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.url_shortener_table.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy_attachment" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_dynamodb_access_policy.arn
}

# DynamoDB table
resource "aws_dynamodb_table" "url_shortener_table" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "short_url"

  attribute {
    name = "short_url"
    type = "S"
  }
}

# App code | Lambda Function to create and fetch short url | persistance in dynamodb
resource "aws_lambda_function" "url_shortener_function" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 10
  memory_size   = 128
  filename      = var.s3_key != "" ? null : "../lambda/lambda.zip"
  s3_bucket     = var.s3_bucket
  s3_key        = var.s3_key

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.url_shortener_table.name
      AUTH_TOKEN = var.auth_token
    }
  }
}

# Exposing the app | API Gateway | Lambda - APIGW Integration & Permissions
resource "aws_apigatewayv2_api" "url_shortener_api" {
  name          = "url-shortener-api-dev"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.url_shortener_api.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.url_shortener_function.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "shorten" {
  api_id    = aws_apigatewayv2_api.url_shortener_api.id
  route_key = "POST /shorten"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "revert" {
  api_id    = aws_apigatewayv2_api.url_shortener_api.id
  route_key = "GET /get_original_url/{short_url}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.url_shortener_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.url_shortener_function.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.url_shortener_api.execution_arn}/*/*"
}
