output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_cluster_ca" {
  value = aws_eks_cluster.eks_cluster.certificate_authority
}

output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "oidc" {
  value = aws_eks_cluster.eks_cluster.identity # .0.oidc.0.issuer
}
