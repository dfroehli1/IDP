variable "bucket_name" {
  type = string
}

variable "lambda_name" {
  type = string
}

variable "image_uri" {
  type = string
}

variable "lambda_role_arn" {
  type = string
}

variable "ecr_repo_name" {
  type    = string
  default = "lambda-app"
}
