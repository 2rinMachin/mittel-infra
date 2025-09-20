output "ingesta_ip" {
  description = "Public IP of MV Ingesta"
  value       = aws_instance.mv_ingesta.public_ip
}
