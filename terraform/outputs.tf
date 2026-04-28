output "public_ip" {
  description = "Public IP da EC2"
  value       = aws_instance.k8s.public_ip
}

output "github_actions_role_arn" {
  description = "ARN da role usada pelo GitHub Actions via OIDC"
  value       = aws_iam_role.github_actions.arn
}