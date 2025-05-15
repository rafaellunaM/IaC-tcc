terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

locals {
  access_aws = chomp(regex("AWS_ACCESS_KEY_ID=(.*)", file("../config/aws.env"))[0])
  secret_aws = chomp(regex("AWS_SECRET_ACCESS_KEY=(.*)", file("../config/aws.env"))[0])
  region   = var.config[0].eks.region
}

provider "aws" {
  region     = local.region
  access_key = local.access_aws
  secret_key = local.secret_aws
}

data "aws_eks_cluster" "eks_cluster" {
  name = module.eks.eks_cluster_name

  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "eks_cluster" {
  name = module.eks.eks_cluster_name
  depends_on = [module.eks]
}

data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks_cluster.token
}

provider "kubectl" {
  alias                  = "gavinbunney"
  host                   = data.aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks_cluster.token
  load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks_cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks_cluster.token
  }
}


module "eks" {
  source = "./modules/eks"
  config = var.config
  eks_cluster_role_arn = module.iam.eks_cluster_role_arn
  subnet_ids = module.vpc.aws_subnet_ids
  dependency_eks_cluster_policy_attachment = module.iam.attachment_eks_cluster_policy
  eks_node_role_arn = module.iam.eks_node_role_arn
}

module "iam"{
  source = "./modules/iam"
  cluster_identity_oidc = module.eks.oidc[0].oidc[0].issuer
}

module "vpc" {
  source = "./modules/vpc"
  aws_availability_zones = data.aws_availability_zones.available.names
}

module "cert-manager" {
  source = "./modules/cert-manager"
  config = var.config
  providers = {
    kubectl = kubectl.gavinbunney
  }
}

module "ebs" {
  source = "./modules/ebs"
  config = var.config
  ebs_csi_irsa_role_arn = module.iam.ebs_csi_irsa_role_arn
  providers = {
    kubectl = kubectl.gavinbunney
  }
}

module "ingress" {
  source = "./modules/ingress"
  config = var.config
}
