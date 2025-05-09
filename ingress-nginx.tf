locals {
  nginx   = var.config[0].nginx
}

resource "helm_release" "ingress-nginx" {
  name             = local.nginx.nginx_name
  repository       = local.nginx.nginx_repository
  chart            = local.nginx.nginx_chart
  namespace        = local.nginx.nginx_namespace
  create_namespace = local.nginx.nginx_create_namespace
  version          = local.nginx.nginx_version
}
