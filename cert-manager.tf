resource "null_resource" "kubectl_apply" {
  provisioner "local-exec" {
    # remeber to adjust this command to fild correct after create terraform modules
    command = "kubectl apply -f ${path.module}/${var.crtm.cert_manager_crd}"
  }
}

resource "helm_release" "cert-manager" {
  name             = var.crtm.cert_manager_name
  repository       = var.crtm.cert_manager_repository
  chart            = var.crtm.cert_manager_chart
  namespace        = var.crtm.cert_manager_namespace
  create_namespace = true
  version          = var.crtm.cert_manager_version

  depends_on = [
    null_resource.kubectl_apply
  ]
}

resource "null_resource" "letsencrypt" {
  provisioner "local-exec" {
    # remeber to adjust this command to fild correct after create terraform modules
    command = "kubectl apply -f ${path.module}/deploymnts/${var.crtm.cert_manager_letsencrypt}"
  }
  
  depends_on = [
    helm_release.cert-manager
  ]
}
