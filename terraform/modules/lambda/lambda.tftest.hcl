#Tests that the lambda module configures the function, IAM role, and API Gateway correctly:


mock_provider "aws" {}

run "lambda_config_and_iam_naming" {
  command = plan

  variables {
    lambda_name = "myapp-lambda"
    image_uri   = "123456789012.dkr.ecr.us-east-1.amazonaws.com/myapp:latest"
    bucket_name = "myapp-bucket"
  }

  # Lambda function name matches the variable
  assert {
    condition     = aws_lambda_function.this.function_name == "myapp-lambda"
    error_message = "Lambda function name must equal var.lambda_name"
  }

  # Timeout and memory are set to expected values
  assert {
    condition     = aws_lambda_function.this.timeout == 30
    error_message = "Lambda timeout must be 30 seconds"
  }

  assert {
    condition     = aws_lambda_function.this.memory_size == 512
    error_message = "Lambda memory_size must be 512 MB"
  }

  # IAM role follows the {lambda_name}-role naming convention
  assert {
    condition     = aws_iam_role.lambda_exec.name == "myapp-lambda-role"
    error_message = "IAM role name must be var.lambda_name + '-role'"
  }

  # API Gateway uses HTTP (not REST/WebSocket)
  assert {
    condition     = aws_apigatewayv2_api.this.protocol_type == "HTTP"
    error_message = "API Gateway must use HTTP protocol type"
  }

  # Route is wired to POST /events
  assert {
    condition     = aws_apigatewayv2_route.post_events.route_key == "POST /events"
    error_message = "API Gateway route key must be 'POST /events'"
  }
}
