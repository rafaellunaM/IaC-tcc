output "cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
  description = "The name of the created EKS cluster."
}

output "region" {
  value = data.aws_region.current
  description = "The region"
}

resource "local_file" "eks_info" {
  content =  join("\n", [aws_eks_cluster.eks_cluster.name, data.aws_region.current.name])
  filename = "eks_info.txt"
}

