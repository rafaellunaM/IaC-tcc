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
