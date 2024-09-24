module "webapp" {
  source                                  = "../../modules/webapp"
  kotolab_net_ca_certificate_arn          = var.kotolab_net_ca_certificate_arn
  blog_api_function_https_endpoint_domain = module.api.blog_api_function_https_endpoint_domain
  blog_api_function_name                  = module.api.blog_api_function_name
  env                                     = var.env
}
