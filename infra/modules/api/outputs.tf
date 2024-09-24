output "blog_api_function_name" {
  value = aws_lambda_function.kotolab_blog_api.function_name
}

output "blog_api_function_arn" {
  value = aws_lambda_function.kotolab_blog_api.arn
}

output "blog_api_function_https_endpoint_domain" {
  value = "${aws_lambda_function_url.kotolab_blog_api.url_id}.lambda-url.ap-northeast-1.on.aws"
}

output "blog_api_function_https_endpoint_url" {
  value = aws_lambda_function_url.kotolab_blog_api.function_url
}
