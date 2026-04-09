output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.s3.bucket_name
}
output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.lambda_function_name
}
output "image_uri" {
  description = "image_uri"
  value       = module.image_uri
}
output "ecr_repo_url" {
  value = aws_ecr_repository.lambda_repo.repository_url
}
