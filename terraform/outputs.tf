output "api_gateway_invoke_url" {
  description = "Base URL for the deployed API Gateway endpoint"
  value       = aws_apigatewayv2_stage.default.invoke_url
}

output "lambda_function_name" {
  description = "Name of the deployed Lambda function"
  value       = aws_lambda_function.url_shortener_function.function_name
}

output "dynamodb_table_name" {
  description = "DynamoDB table name used for storage"
  value       = aws_dynamodb_table.url_shortener_table.name
}