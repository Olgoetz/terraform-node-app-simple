output "ec2_public_dns" {
  value       = "http://${aws_instance.node.public_dns}"
  description = "Public DNS for the instance"
}

output "ec2_public_ip" {
  value       = aws_instance.node.public_ip
  description = "Public IP for the instance"
}

output "ec2_name" {
  value       = aws_instance.node.tags.Name
  description = "Name of the ec2 instance"
}

output "ec2_id" {
  value       = aws_instance.node.id
  description = "ID of the ec2 instance"
}

output "caller_identity" {
  value       = data.aws_caller_identity.this
  description = "Caller identiy"
}

output "ec2_private_key_pem" {
  value       = trimspace(tls_private_key.ec2.private_key_pem)
  sensitive   = true
  description = "Private key in pem format for accessing ec2 instance"
}