variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "S3 bucket for Terraform state"
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB table for Terraform locking"
  type        = string
  default     = "idp-terraform-locks"
}

variable "ecr_repo_name" {
  description = "ECR repository for Lambda container"
  type        = string
  default     = "idp-lambda"
}
