locals {
  eks   = var.config[0].eks
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = local.eks.cluster_name
  role_arn = var.eks_cluster_role_arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [
    var.dependency_eks_cluster_policy_attachment
  ]

}

resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = local.eks.node_group_name
  node_role_arn   = var.eks_node_role_arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = local.eks.scaling_config_desired_size
    max_size     = local.eks.scalling_cluster_max
    min_size     = local.eks.scalling_cluster_min
  }

  instance_types = [local.eks.instance_types]

  depends_on = [
    var.dependency_eks_cluster_policy_attachment
  ]
}

data "aws_eks_cluster" "eks_cluster" {
  name = aws_eks_cluster.eks_cluster.name
}

data "aws_eks_cluster_auth" "eks_cluster" {
  name = aws_eks_cluster.eks_cluster.name
}
