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
    # key is passed at init time: -backend-config="key=infra/<app_name>/terraform.tfstate"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "infra" {
  source = "../modules/infra"

  bucket_name   = var.bucket_name
  ecr_repo_name = var.ecr_repo_name
}
