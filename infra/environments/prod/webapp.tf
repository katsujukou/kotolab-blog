module "webapp" {
  source = "../../modules/webapp"
  kotolab_net_ca_certificate_arn = var.kotolab_net_ca_certificate_arn
  env = var.env
}