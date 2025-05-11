resource "kubernetes_secret" "aws_credentials" {
  metadata {
    name = "aws-env"
  }
  data = {
    AWS_ACCESS_KEY_ID   = local.access_aws 
    AWS_SECRET_ACCESS_KEY  = local.secret_aws
    EKS_CLUSTER_NAME = local.eks.cluster_name
    EKS_REGION = local.eks.region
  }
}

resource "kubernetes_config_map" "install_tools" {
  metadata {
    name = "install-tools"
  }
  data = {
    "install-tools.sh" = "${file("${path.module}/deployments/install-tools.yaml")}"
  }
  depends_on = [ kubernetes_secret.aws_credentials ]
}

resource "kubernetes_config_map" "install_HLF" {
  metadata {
    name = "install-hlf"
  }
  data = {
    "tools-hlf.sh" = "${file("${path.module}/deployments/install-hlf.yaml")}"
  }
  depends_on = [ kubernetes_config_map.install_tools ]
}

resource "kubectl_manifest" "toolbox_container" {
  yaml_body =  "${file("${path.module}/deployments/toolbox.yaml")}"
  depends_on = [ kubernetes_config_map.install_HLF ]
}

# Service account to test environment, Is necessary createe other service account with specific roles
resource "kubernetes_cluster_role_binding" "default_admin" {
  metadata {
    name = "default-admin"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "default"
  }
}
