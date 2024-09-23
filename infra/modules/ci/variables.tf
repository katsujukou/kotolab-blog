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