output "cluster_name" {
  value =  var.config[0].eks.cluster_name
  description = "The name of the created EKS cluster."
}

output "region" {
  value = data.aws_region.current
  description = "The region"
}

resource "local_file" "eks_info" {
  content =  join("\n", [ var.config[0].eks.cluster_name, data.aws_region.current.name])
  filename = "eks_info.txt"
}
