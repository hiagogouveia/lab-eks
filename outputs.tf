output "cluster_name" {
  value = module.eks.cluster_name
}

output "region" {
  value = var.aws_region
}

output "configure_kubectl" {
  value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${var.cluster_name}"
}

output "grafana_iam_role_arn" {
  description = "O ARN do papel IAM para o Grafana (use isso no Helm)"
  value       = aws_iam_role.grafana_role.arn
}