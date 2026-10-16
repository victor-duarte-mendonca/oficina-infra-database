resource "aws_security_group" "rds" {
  name_prefix = "${local.name_prefix}-rds-"
  description = "RDS PostgreSQL: 5432 apenas dos clientes autorizados"
  vpc_id      = local.vpc_id

  tags = { Name = "${local.name_prefix}-rds-sg" }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "from_k3s" {
  security_group_id            = aws_security_group.rds.id
  description                  = "PostgreSQL apenas da EC2 do k3s"
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  referenced_security_group_id = local.k3s_security_group_id
}

# O ingresso do Lambda de autenticação NÃO é criado aqui: o SG do Lambda só existe quando o
# repositório oficina-auth-lambda é aplicado, depois deste. Esse repositório lê
# /oficina/<env>/rds_security_group_id (ssm_outputs.tf) e cria a própria regra 5432 neste SG.
#
# Sem regra de egress: o RDS não inicia conexões (subnets privadas, sem NAT). Ao gerenciar o
# SG pelo Terraform a regra de saída padrão da AWS é removida, o que é o comportamento desejado.
