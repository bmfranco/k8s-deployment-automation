output "public_ip" {
  description = "Public IP da EC2"
  value       = aws_instance.k8s.public_ip
}

output "ssh_command" {
  description = "Comando para acessar via SSH"
  value       = "ssh ec2-user@${aws_instance.k8s.public_ip}"
}

output "ssm_command" {
  description = "Comando para acessar via AWS SSM"
  value       = "aws ssm start-session --target ${aws_instance.k8s.id}"
}

output "app_url_minikube" {
  description = "URL da aplicação (via minikube service)"
  value       = "Execute: minikube service nginx --url"
}