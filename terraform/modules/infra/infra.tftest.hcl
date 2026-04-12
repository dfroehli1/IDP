#Tests that the infra module creates an S3 bucket and ECR repo with the correct names and settings:

mock_provider "aws" {}

run "infra_resource_names_match_variables" {
  command = plan

  variables {
    bucket_name   = "myapp-bucket"
    ecr_repo_name = "myapp"
  }

  assert {
    condition     = aws_s3_bucket.bucket.bucket == "myapp-bucket"
    error_message = "S3 bucket name must equal var.bucket_name"
  }

  assert {
    condition     = aws_ecr_repository.repo.name == "myapp"
    error_message = "ECR repo name must equal var.ecr_repo_name"
  }

  assert {
    condition     = aws_ecr_repository.repo.force_delete == true
    error_message = "ECR repo must have force_delete = true so CI can destroy it cleanly"
  }
}
