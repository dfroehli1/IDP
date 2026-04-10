output "ecr_repo_url" {
  value = aws_ecr_repository.repo.repository_url
}

output "bucket_name" {
  value = aws_s3_bucket.bucket.bucket
}
