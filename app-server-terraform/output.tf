output "private-key" {
  value = tls_private_key.private-key.private_key_pem
  sensitive = true
}

output "public-key-openssh" {
  value = tls_private_key.private-key.public_key_openssh
}

output "control-node" {
  value = aws_instance.web.*.public_ip[0]
}

output "client-node" {
  value = aws_instance.web.*.public_ip[1]
}
