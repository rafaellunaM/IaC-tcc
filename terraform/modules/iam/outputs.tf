output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster_role.arn
}

output "attachment_eks_cluster_policy" {
  value = aws_iam_role_policy_attachment.eks_cluster_policy
}

output "attachment_eks_node_policies" {
  value = aws_iam_role_policy_attachment.eks_node_policies
}

output "eks_node_role_arn" {
  value = aws_iam_role.eks_node_role.arn
}
 
output "ebs_csi_irsa_role_arn" {
  value = aws_iam_role.ebs_csi_irsa_role.arn
}
