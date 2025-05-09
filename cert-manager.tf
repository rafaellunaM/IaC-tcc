locals {
  crtm   = var.config[0].crtm
}

resource "null_resource" "kubectl_apply_crd" {
  provisioner "local-exec" {
    # remeber to adjust this command to fild correct after create terraform modules
    command = "kubectl apply -f ${path.module}/${local.crtm.cert_manager_crd}"
  }
}

resource "helm_release" "cert-manager" {
  name             = local.crtm.cert_manager_name
  repository       = local.crtm.cert_manager_repository
  chart            = local.crtm.cert_manager_chart
  namespace        = local.crtm.cert_manager_namespace
  create_namespace = true
  version          = local.crtm.cert_manager_version

  depends_on = [
    null_resource.kubectl_apply_crd
  ]
}

resource "null_resource" "letsencrypt" {
  provisioner "local-exec" {
    # remeber to adjust this command to fild correct after create terraform modules
    command = "kubectl apply -f ${path.module}/deploymnts/${local.crtm.cert_manager_letsencrypt}"
  }
  
  depends_on = [
    helm_release.cert-manager
  ]
}
