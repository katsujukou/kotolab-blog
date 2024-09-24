module "api" {
  source                 = "../../modules/api"
  env                    = var.env
  blog_api_function_name = "${var.env}-kotolab-blog-api-function"
}
