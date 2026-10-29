output "vpc_id" {
  description = "ID da VPC (consumir no k8s-infra / Lambda VPC config)"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR da VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "Subnets públicas (ALB / NAT)"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Subnets privadas (EKS nodes / RDS / Lambda)"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_id" {
  description = "NAT Gateway (custo relevante — destroy fora de demo)"
  value       = aws_nat_gateway.main.id
}

output "rds_endpoint" {
  description = "Hostname do RDS (JDBC host)"
  value       = aws_db_instance.postgres.address
}

output "rds_port" {
  description = "Porta PostgreSQL"
  value       = aws_db_instance.postgres.port
}

output "rds_db_name" {
  description = "Nome do database"
  value       = aws_db_instance.postgres.db_name
}

output "rds_username" {
  description = "Usuário master"
  value       = aws_db_instance.postgres.username
  sensitive   = true
}

output "rds_security_group_id" {
  description = "SG do RDS — k8s-infra pode referenciar para regras adicionais"
  value       = aws_security_group.rds.id
}

output "jdbc_url" {
  description = "URL JDBC pronta para a aplicação core"
  value       = "jdbc:postgresql://${aws_db_instance.postgres.address}:${aws_db_instance.postgres.port}/${aws_db_instance.postgres.db_name}"
}
