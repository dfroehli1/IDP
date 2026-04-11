variable "bucket_name" {
  type = string
}

variable "lambda_name" {
  type = string
}

variable "image_uri" {
  default = ""
}

variable "lambda_role_arn" {
  default = ""
}

variable "ecr_repo_name" {
  type    = string
  default = "idp-lambda"
}
