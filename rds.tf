# Versão efetivamente oferecida na região/conta (Learner Lab costuma
# não ter a mesma matriz de minors da conta comercial — preferred_versions
# fixas falham com "no RDS engine versions match").
# `version = null` omite o filtro → provider devolve a mais recente disponível.
data "aws_rds_engine_version" "postgres" {
  engine  = "postgres"
  version = var.db_engine_version
}

locals {
  postgres_engine_version = data.aws_rds_engine_version.postgres.version
  postgres_family         = data.aws_rds_engine_version.postgres.parameter_group_family
}

resource "aws_db_subnet_group" "main" {
  name       = "${local.name_prefix}-db-subnets"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${local.name_prefix}-db-subnets"
  }
}

resource "aws_db_parameter_group" "postgres" {
  name   = "${local.name_prefix}-${replace(local.postgres_family, "_", "-")}"
  family = local.postgres_family

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  tags = {
    Name = "${local.name_prefix}-${local.postgres_family}"
  }
}

resource "aws_db_instance" "postgres" {
  identifier = "${local.name_prefix}-postgres"

  engine                = "postgres"
  engine_version        = local.postgres_engine_version
  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_allocated_storage * 2
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.postgres.name
  publicly_accessible    = var.db_publicly_accessible
  multi_az               = var.db_multi_az

  backup_retention_period = var.environment == "prod" ? 7 : 1
  skip_final_snapshot     = var.environment != "prod"
  deletion_protection     = var.environment == "prod"
  apply_immediately       = var.environment != "prod"

  tags = {
    Name = "${local.name_prefix}-postgres"
  }
}
