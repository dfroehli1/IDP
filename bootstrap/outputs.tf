output "state_bucket_name" {
  value = aws_s3_bucket.tf_state.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.tf_locks.name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.lambda_repo.repository_url
}
