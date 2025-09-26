output "vm_prod_1_ip" {
  description = "Public IP of Mittel Prod 1 VM"
  value       = aws_instance.vm_prod_1.public_ip
}

output "vm_prod_2_ip" {
  description = "Public IP of Mittel Prod 1 VM"
  value       = aws_instance.vm_prod_2.public_ip
}

output "vm_databases_public_ip" {
  description = "Public IP of Mittel Databases VM"
  value       = aws_instance.vm_dbs.public_ip
}

output "vm_databases_private_ip" {
  description = "Public IP of Mittel Databases VM"
  value       = aws_instance.vm_dbs.private_ip
}

output "vm_ingesta_ip" {
  description = "Public IP of Mittel Ingesta VM"
  value       = aws_instance.vm_ingesta.public_ip
}

output "prod_alb_url" {
  description = "URL of the Prod ALB"
  value       = aws_lb.prod_alb.dns_name
}
