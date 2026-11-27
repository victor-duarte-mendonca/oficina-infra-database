# Banco do Billing Service (Fase 4, spec 12 §1): instancia PostgreSQL PROPRIA, no mesmo subnet group, parameter group
# (TLS obrigatorio) e security group do RDS do OS (5432 so do no do k3s).
#
# Por que instancia separada e nao um database dentro do RDS atual: o Terraform roda fora da VPC e nao consegue
# executar "CREATE DATABASE" numa instancia privada; so o db_name inicial e criado pelo provider. Uma instancia
# propria entrega o isolamento de dados de verdade (database por servico) com so Terraform, ao custo de ~US$0,016/h
# e de alguns minutos a mais na subida. Se o saldo apertar, da para apontar o Billing ao RDS do OS (limitacao: o
# Flyway do Billing teria de usar um schema proprio).
#
# Credenciais: o mesmo usuario/senha do RDS do OS (decisao registrada no PROGRESSO; debito: role propria depois).
resource "aws_db_instance" "billing" {
  identifier             = "${local.name_prefix}-billing-postgres"
  engine                 = "postgres"
  engine_version         = "16"
  instance_class         = var.db_instance_class
  allocated_storage      = 20
  storage_type           = "gp3"
  db_name                = var.billing_db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  parameter_group_name   = aws_db_parameter_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  # Pagamentos e e-mail do cliente: criptografia em repouso, igual ao RDS do OS.
  storage_encrypted   = true
  publicly_accessible = false

  # Valores de laboratorio (ver rds.tf): sem Multi-AZ, sem protecao contra delete (o destroy e obrigatorio ao fim
  # de cada sessao) e sem snapshot final.
  multi_az                   = false
  backup_retention_period    = local.config.backup_retention_period
  deletion_protection        = false
  skip_final_snapshot        = true
  auto_minor_version_upgrade = true

  tags = { Name = "${local.name_prefix}-billing-postgres" }
}
