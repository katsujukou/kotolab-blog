variable "env" {
  type = string  
}

variable "github_username" {
  type = string
  default = "katsujukou"
}

variable "github_repo" {
  type = string
  default = "kotolab-blog"
}

variable "webapp_s3_bucket_arn" {
  type = string
}

variable "webapp_cloudfront_distribution_arn" {
  type = string
}

variable "blog_api_function_arn" {
  type = string
}