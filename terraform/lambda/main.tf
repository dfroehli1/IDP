module "lambda" {
  source = "../modules/lambda"

  lambda_name     = var.lambda_name
  image_uri       = var.image_uri
  bucket_name     = var.bucket_name
}
terraform {
  backend "s3" {
    bucket         = "team-deb-terraform-state"
    key            = "lambda/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-locks"
    encrypt        = true
  }
}
