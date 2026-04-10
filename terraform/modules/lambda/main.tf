resource "aws_lambda_function" "this" {
  function_name = var.lambda_name
  package_type  = "Image"
  image_uri     = var.image_uri

  role = var.lambda_role_arn

  timeout     = 30
  memory_size = 512

  environment {
    variables = {
      BUCKET_NAME = var.bucket_name
   }
  }
}
