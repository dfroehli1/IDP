module "infra" {
  source = "../modules/infra"

  bucket_name   = var.bucket_name
  ecr_repo_name = var.ecr_repo_name
}
terraform {
  backend "s3" {
    bucket         = "team-deb-terraform-state"
    key            = "infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "idp-terraform-locks"
    encrypt        = true
  }
}
