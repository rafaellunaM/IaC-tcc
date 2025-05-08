
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.eks.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = aws_subnet.eks[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = var.eks.node_group_name
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = aws_subnet.eks[*].id

  scaling_config {
    desired_size = var.eks.scaling_config_desired_size
    max_size     = var.eks.scalling_cluster_max
    min_size     = var.eks.scalling_cluster_min
  }

  instance_types = [var.eks.instance_types]

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_policies
  ]
}

data "aws_eks_cluster" "eks_cluster" {
  name = aws_eks_cluster.eks_cluster.name
}

data "aws_eks_cluster_auth" "eks_cluster" {
  name = aws_eks_cluster.eks_cluster.name
}
