terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}

locals {
  ebs   = var.config[0].ebs
}

resource "helm_release" "ebs_csi_driver" {
  name       = local.ebs.ebs_name
  repository = local.ebs.ebs_repository
  chart      = local.ebs.ebs_chart
  namespace  = local.ebs.ebs_namespace
  version    = local.ebs.ebs_version

  set {
    name  = "controller.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "controller.serviceAccount.name"
    value = "ebs-csi-controller-sa"
  }

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.ebs_csi_irsa_role_arn
  }
}

resource "kubectl_manifest" "create_sc" {
  yaml_body = <<YAML
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-csi-sc
provisioner: ebs.csi.aws.com
parameters:
  type: gp2
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
YAML
depends_on = [ helm_release.ebs_csi_driver ]
}

resource "kubectl_manifest" "create_pvc" {
  yaml_body = <<YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ebs-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: ebs-csi-sc
  resources:
    requests:
      storage: 5Gi
YAML
depends_on = [ kubectl_manifest.create_sc ]
}
