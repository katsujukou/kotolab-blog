module "ci" {
  source = "../../modules/ci"
  env = var.env
  webapp_s3_bucket_arn = module.webapp.webapp_s3_bucket_arn
}