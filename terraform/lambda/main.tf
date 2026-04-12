terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
  backend "s3" {
    bucket         = "team-deb-terraform-state"
    region         = "us-east-1"
    dynamodb_table = "idp-terraform-locks"
    encrypt        = true
    # key is passed at init time: -backend-config="key=lambda/<app_name>/terraform.tfstate"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "lambda" {
  source = "../modules/lambda"

  lambda_name = var.lambda_name
  image_uri   = var.image_uri
  bucket_name = var.bucket_name
}
