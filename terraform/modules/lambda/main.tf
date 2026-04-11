resource "aws_iam_role" "lambda_exec" {
  name = "${var.lambda_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "this" {
  function_name = var.lambda_name
  package_type  = "Image"
  image_uri     = var.image_uri

  role = aws_iam_role.lambda_exec.arn

  timeout     = 30
  memory_size = 512

  environment {
    variables = {
      BUCKET_NAME = var.bucket_name
    }
  }
}
