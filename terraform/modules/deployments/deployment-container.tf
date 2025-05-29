terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}

locals {
  access_aws = chomp(regex("AWS_ACCESS_KEY_ID=(.*)", file("../config/aws.env"))[0])
  secret_aws = chomp(regex("AWS_SECRET_ACCESS_KEY=(.*)", file("../config/aws.env"))[0])
  eks_cluster_name = var.config[0].eks.cluster_name
  eks_region = var.config[0].eks.region
}

# TO DO: Parametrize this resource
resource "helm_release" "hlf_chart" {
  name             = "kfs"
  repository       = "https://kfsoftware.github.io/hlf-helm-charts"
  chart            = "hlf-operator"
  namespace        = "default"
  create_namespace = false
  version          = "1.11.1"
}

resource "kubernetes_secret" "aws_credentials" {
  metadata {
    name = "aws-env"
  }
  data = {
    AWS_ACCESS_KEY_ID   = local.access_aws 
    AWS_SECRET_ACCESS_KEY  = local.secret_aws
    EKS_CLUSTER_NAME = local.eks_cluster_name
    EKS_REGION = local.eks_region
  }
}

resource "kubernetes_secret" "config_hlf_env" {
  metadata {
    name = "config-hlf-env"
  }
  data = {  
    PEER_IMAGE = "hyperledger/fabric-peer"
    PEER_VERSION = "3.0.0"
    ORDERER_IMAGE = "hyperledger/fabric-orderer"
    ORDERER_VERSION = "3.0.0"
    CA_IMAGE = "hyperledger/fabric-ca"
    CA_VERSION = "1.5.13"
    SC_NAME="ebs-csi-sc"
  }
}

resource "kubernetes_config_map" "install_tools" {
  metadata {
    name = "install-tools"
  }
  data = {
    "install-tools.sh" = "${file("${path.module}/scripts/install-tools.sh")}"
  }
  depends_on = [ kubernetes_secret.aws_credentials ]
}

resource "kubernetes_config_map" "install_HLF" {
  metadata {
    name = "install-hlf"
  }
  data = {
    "hlf-operator.sh" = "${file("${path.module}/scripts/hlf-operator.sh")}"
    "install-istio.sh" = "${file("${path.module}/scripts/install-istio.sh")}"
    "config-coreDns.sh" = "${file("${path.module}/scripts/config-coreDns.sh")}"
    
    "output.json" = "${file("${path.module}/code/output.json")}"
    # "create-cas.go" = "${file("${path.module}/code/create-cas.go")}"

    # "register-user-peers-cas.go" = "${file("${path.module}/code/register-user-peers-cas.go")}"
    # "deploy-peers.go" = "${file("${path.module}/code/deploy-peers.go")}"

    # "register-user-orderes-cas.go" = "${file("${path.module}/code/register-user-orderes-cas.go")}"
    # "deploy-orderer.go" = "${file("${path.module}/code/deploy-orderer.go")}"

    # # Register and enrolling OrdererMSP identity
    # "channel-ca-register.go" = "${file("${path.module}/code/channel-ca-register.go")}"
    # "channel-ca-enroll.go" = "${file("${path.module}/code/channel-ca-enroll.go")}"

    # "create-generic-wallet.go" = "${file("${path.module}/code/create-generic-wallet.go")}"
    
    # "create-main-channel.go" = "${file("${path.module}/code/create-main-channel.go")}"
    # "join-channel.go" = "${file("${path.module}/code/join-channel.go")}"
  }
  depends_on = [ kubernetes_config_map.install_tools ]
}

resource "kubectl_manifest" "toolbox_container" {
  yaml_body =  "${file("${path.module}/manifests/toolbox.yaml")}"
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
