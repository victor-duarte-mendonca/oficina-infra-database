# Spec 07 §3. pg_stat_statements e Performance Insights ficam de fora de propósito: o primeiro
# exige reboot e não se sustenta num banco recriado a cada sessão; o segundo arrisca custo
# silencioso na classe t4g.micro.
resource "aws_db_parameter_group" "main" {
  name_prefix = "${local.name_prefix}-pg16-"
  family      = "postgres16"
  description = "Oficina PostgreSQL 16: consulta lenta, conexoes e TLS obrigatorio"

  # Evidência objetiva quando o alerta de latência p95 disparar.
  parameter {
    name  = "log_min_duration_statement"
    value = "500"
  }

  # Diagnostica esgotamento de pool e conexões do Lambda (teto de ~112 no t4g.micro).
  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  # TLS em toda conexão. Mudança coordenada: a aplicação e o Lambda precisam de sslmode=require.
  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  tags = { Name = "${local.name_prefix}-pg16" }

  lifecycle {
    create_before_destroy = true
  }
}
