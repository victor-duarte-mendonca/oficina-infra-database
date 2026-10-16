resource "aws_db_instance" "main" {
  identifier             = "${local.name_prefix}-postgres"
  engine                 = "postgres"
  engine_version         = "16"
  instance_class         = var.db_instance_class
  allocated_storage      = 20
  storage_type           = "gp3"
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  parameter_group_name   = aws_db_parameter_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  # Criptografia em repouso com a chave gerenciada da AWS. O default do provider é
  # false — o banco guarda CPF/CNPJ, e-mail e telefone de clientes, então isto não é
  # opcional. Custo zero com a chave padrão do serviço.
  storage_encrypted = true

  # Só aceita conexão por dentro da VPC (ver security_group.tf).
  publicly_accessible = false

  # ---------------------------------------------------------------------------
  # Valores de LABORATÓRIO, declarados explicitamente para que a escolha fique
  # visível no código em vez de virem por omissão do provider:
  #
  #   multi_az            = false → sem réplica em outra AZ. Um failover de AZ derruba
  #                                 o banco. Em produção real: true (dobra o custo).
  #   backup_retention... = 0 (hml) / 1 (prod) → ver locals.tf. Em produção real: 7 a 35 dias.
  #   deletion_protection = false → permite `terraform destroy`, que aqui é obrigatório
  #                                 ao final de cada sessão. Em produção real: true.
  # ---------------------------------------------------------------------------
  multi_az                = false
  backup_retention_period = local.config.backup_retention_period
  deletion_protection     = false
  skip_final_snapshot     = true

  # Correções de segurança do PostgreSQL entram na próxima janela de manutenção sem
  # intervenção — o oposto (ficar preso a um patch vulnerável) é o risco maior.
  auto_minor_version_upgrade = true

  tags = { Name = "${local.name_prefix}-postgres" }
}
