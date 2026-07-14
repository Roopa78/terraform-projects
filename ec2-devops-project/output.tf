output "public_ip" {
  value = aws_instance.devops_server.public_ip
}

output "public_dns" {
  value = aws_instance.devops_server.public_dns
}
