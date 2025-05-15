variable "config" {
  description = "Env config"
  type        = any
}

variable "eks_cluster_role_arn" {
  description = "ARN from IAM Role for EKS Cluster"
  type        = string
}

variable "eks_node_role_arn" {
  description = "ARN from IAM Role for nodes  EKS"
  type        = string
}

variable "subnet_ids" {
  description = "subnets IDs list"
  type        = list(string)
}

variable "dependency_eks_cluster_policy_attachment" {
  type        = any
}
