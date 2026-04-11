resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}

resource "aws_ecr_repository" "repo" {
  name = var.ecr_repo_name

  force_delete = true

  lifecycle {
    prevent_destroy = false
  }
}
