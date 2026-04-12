resource "aws_s3_bucket" "bucket" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_ecr_repository" "repo" {
  name         = var.ecr_repo_name
  force_delete = true
}
