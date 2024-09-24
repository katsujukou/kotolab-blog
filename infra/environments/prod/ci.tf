module "ci" {
  source = "../../modules/ci"
  env                                = var.env
  webapp_s3_bucket_arn               = module.webapp.webapp_s3_bucket_arn
  webapp_cloudfront_distribution_arn = module.webapp.cloudfront_distribution_arn
  blog_api_function_arn              = module.api.blog_api_function_arn
}