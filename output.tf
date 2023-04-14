output "server_ip" {
  value = aws_instance.unirep_rancher_server.public_ip
}
