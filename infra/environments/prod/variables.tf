variable "env" {
  type = string
  default = "prod"  
}

variable "kotolab_net_ca_certificate_arn" {
  type = string
  default = "arn:aws:acm:us-east-1:678017164418:certificate/d0c1a7cd-8c6a-4fb1-9bda-a10e338c84dd"
}