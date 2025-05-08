resource "helm_release" "ebs_csi_driver" {
  name       = var.ebs.ebs_name
  repository = var.ebs.ebs_repository
  chart      = var.ebs.ebs_chart
  namespace  = var.ebs.ebs_namespace
  version    = var.ebs.ebs_version

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
    value = aws_iam_role.ebs_csi_irsa_role.arn
  }
}

resource "null_resource" "kubectl_apply_sc" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/deployments/${var.ebs.ebs_sc_default_file}"
  }
  depends_on = [ helm_release.ebs_csi_driver ]
}

resource "null_resource" "kubectl_apply_pvc" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/deployments/${var.ebs.ebs_pvc_default_file}"
  }

  depends_on = [ null_resource.kubectl_apply_sc ]
}
