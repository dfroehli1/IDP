module "lambda" {
  source = "../modules/lambda"

  lambda_name     = var.lambda_name
  image_uri       = var.image_uri
  bucket_name     = var.bucket_name
}

