data "archive_file" "sample_function" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/dist.zip"
}

resource "aws_iam_role" "api_function_role" {
  name = "for-kotolab-blog-api-lambda-function"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "api_function_policy" {
  role       = aws_iam_role.api_function_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "kotolab_blog_api" {
  filename         = data.archive_file.sample_function.output_path
  function_name    = var.blog_api_function_name
  role             = aws_iam_role.api_function_role.arn
  handler          = "app.handler"
  publish          = true
  source_code_hash = data.archive_file.sample_function.output_base64sha256
  runtime          = "nodejs20.x"
}

resource "aws_lambda_function_url" "kotolab_blog_api" {
  function_name      = aws_lambda_function.kotolab_blog_api.function_name
  authorization_type = "AWS_IAM"
}

resource "aws_lambda_permission" "allow_cloudwatch_access" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.kotolab_blog_api.function_name
  principal     = "events.amazonaws.com"
}

