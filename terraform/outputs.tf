output "public_ip" {
  value = aws_instance.k8s.public_ip
}

output "private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}