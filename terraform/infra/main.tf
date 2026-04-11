module "infra" {
  source = "../modules/infra"

  bucket_name   = var.bucket_name
  ecr_repo_name = var.ecr_repo_name
}
