output "lambda_name" {
  value = aws_lambda_function.this.function_name
}

output "lambda_arn" {
   value = length(module.lambda) > 0 ? module.lambda[0].lambda_arn : null
}

output "invoke_arn" {
  description = "Invoke ARN for API Gateway or triggers"
  value       = aws_lambda_function.this.invoke_arn
}
