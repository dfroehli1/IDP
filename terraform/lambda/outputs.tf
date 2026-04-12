output "lambda_name" {
  value = module.lambda.lambda_name
}

output "lambda_arn" {
  value = module.lambda.lambda_arn
}

output "api_gateway_url" {
  description = "HTTPS endpoint for POST /events"
  value       = module.lambda.api_gateway_url
}
