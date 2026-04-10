module "infra" {
  source = "./modules/infra"

  bucket_name   = var.bucket_name
  ecr_repo_name = var.ecr_repo_name
}

module "lambda" {
  source = "./modules/lambda"

  lambda_name     = var.lambda_name
  image_uri       = var.image_uri
  lambda_role_arn = var.lambda_role_arn

  count = var.image_uri == "" ? 0 : 1

  depends_on = [module.infra]
}
