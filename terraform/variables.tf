variable "bucket_name" {
  description = "Name of the S3 bucket to create"
  type        = string
}
variable "lambda_name" {
  description = "Name of the lambda function to create"
  type        = string
}
variable "image_uri" {
  description = "uri of the docker image"
  type        = string
}
