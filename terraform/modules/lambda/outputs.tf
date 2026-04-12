output "lambda_name" {
  value = aws_lambda_function.this.function_name
}

output "lambda_arn" {
  value = aws_lambda_function.this.arn
}

output "invoke_arn" {
  description = "Invoke ARN for API Gateway or triggers"
  value       = aws_lambda_function.this.invoke_arn
}

output "api_gateway_url" {
  description = "HTTPS endpoint for POST /events"
  value       = "${aws_apigatewayv2_stage.default.invoke_url}/events"
}
