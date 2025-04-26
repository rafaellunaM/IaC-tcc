resource "null_resource" "kubectl_apply" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/cert-manager-crds.yaml"
  }
}

resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = "1.17.2"

  depends_on = [
    null_resource.kubectl_apply
  ]
}

resource "null_resource" "letsencrypt" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/deployments/letsencrypt-production.yaml"
  }
  
  depends_on = [
    helm_release.cert-manager
  ]
}
