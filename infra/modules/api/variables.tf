variable "env" {
  type = string
}

variable "lambda_file_name" {
  type    = string
  default = "/contents/lambda_function.js"
}

variable "lambda_file_zip_name" {
  type    = string
  default = "/contents/lambda.zip"
}

variable "blog_api_function_name" {
  type = string
}
