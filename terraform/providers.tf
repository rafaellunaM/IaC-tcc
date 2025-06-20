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
