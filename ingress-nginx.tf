resource "helm_release" "ingress-nginx" {
  name             = var.nginx.nginx_name
  repository       = var.nginx.nginx_repository
  chart            = var.nginx.nginx_chart
  namespace        = var.nginx.nginx_namespace
  create_namespace = var.nginx.nginx_create_namespace
  version          = var.nginx.nginx_version
}
