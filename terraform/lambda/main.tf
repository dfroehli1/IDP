module "lambda" {
  source = "../modules/lambda"

  lambda_name     = var.lambda_name
  image_uri       = var.image_uri
  lambda_role_arn = var.lambda_role_arn
  bucket_name     = var.bucket_name
}

