resource "helm_release" "ebs_csi_driver" {
  name       = "aws-ebs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  namespace  = "kube-system"
  version    = "2.42.0"

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
    command = "kubectl apply -f ${path.module}/deployments/sc"
  }
  depends_on = [ helm_release.ebs_csi_driver ]
}

resource "null_resource" "kubectl_apply_pvc" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/deployments/pvc"
  }

  depends_on = [ null_resource.kubectl_apply_sc ]
}
