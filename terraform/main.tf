provider "aws" {
  region = var.region
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
}

module "lambda" {
  source        = "./modules/lambda"
  function_name = var.lambda_name
  image_uri     = var.image_uri
  bucket_name = module.s3.bucket_name
  s3_bucket_arn = module.s3.bucket_arn
}


resource "aws_ecr_repository" "lambda_repo" {
  name = "lambda-app"
}
