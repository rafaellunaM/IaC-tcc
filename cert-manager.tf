locals {
  crtm   = var.config[0].crtm
}

resource "helm_release" "cert-manager" {
  name             = local.crtm.cert_manager_name
  repository       = local.crtm.cert_manager_repository
  chart            = local.crtm.cert_manager_chart
  namespace        = local.crtm.cert_manager_namespace
  create_namespace = true
  version          = local.crtm.cert_manager_version

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "kubectl_manifest" "letsencrypt_issuer" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: letsencrypt-production
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: rafael@gmail.com
    privateKeySecretRef:
      name: letsencrypt-production
    solvers:
      - http01:
          ingress:
            class: nginx
YAML
depends_on = [ helm_release.cert-manager ]
}

  # manifest = {
  #   apiVersion = "cert-manager.io/v1"
  #   kind       = "Issuer"
  #   metadata = {
  #     name      = "letsencrypt-production"
  #     namespace = "cert-manager"
  #   }
  #   spec = {
  #     acme = {
  #       server = "https://acme-v02.api.letsencrypt.org/directory"
  #       email  = "rafael@gmail.com"
  #       privateKeySecretRef = {
  #         name = "letsencrypt-production"
  #       }
  #       solvers = [
  #         {
  #           http01 = {
  #             ingress = {
  #               class = "nginx"
  #             }
  #           }
  #         }
  #       ]
  #     }
  #   }
  # }
  # depends_on = [ helm_release.cert-manager ]

