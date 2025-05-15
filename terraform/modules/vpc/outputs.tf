output "aws_subnet_ids" {
  value = aws_subnet.eks[*].id
}
