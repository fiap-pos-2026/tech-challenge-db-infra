variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "sa-east-1"
}

variable "project_name" {
  description = "Prefixo de nomes dos recursos"
  type        = string
  default     = "tech-challenge"
}

variable "environment" {
  description = "Ambiente (homolog | prod)"
  type        = string
  default     = "homolog"
}

variable "vpc_cidr" {
  description = "CIDR da VPC compartilhada com o EKS"
  type        = string
  default     = "10.0.0.0/16"
}

variable "db_name" {
  description = "Nome do database inicial"
  type        = string
  default     = "techbase"
}

variable "db_username" {
  description = "Usuário master do RDS"
  type        = string
  default     = "techdev"
}

variable "db_password" {
  description = "Senha master do RDS (não versionar — use TF_VAR_db_password ou tfvars local)"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "Classe da instância RDS"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  description = "Storage inicial (GiB)"
  type        = number
  default     = 20
}

variable "db_engine_version" {
  description = "Pin opcional da versão Postgres (ex.: \"15.7\"). null = usar a mais recente oferecida na conta/região (recomendado no AWS Academy)."
  type        = string
  default     = null
  nullable    = true
}

variable "db_multi_az" {
  description = "Multi-AZ (prod). Homolog pode ficar false para economizar créditos"
  type        = bool
  default     = false
}

variable "db_publicly_accessible" {
  description = "Se true, RDS recebe IP público (só para bootstrap/debug — manter false)"
  type        = bool
  default     = false
}

variable "allowed_cidr_blocks" {
  description = "CIDRs extras com acesso à porta 5432 (ex.: VPN). O SG do EKS será liberado depois via k8s-infra"
  type        = list(string)
  default     = []
}
