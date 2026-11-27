# Publicado só depois que a instância está disponível: o recurso aws_db_instance só conclui
# o create nesse estado, então estes parâmetros nunca expõem um endpoint em "creating".
# NENHUMA credencial é publicada: usuário e senha seguem como GitHub Secrets (spec 07 §5).
locals {
  ssm_contract = {
    db_endpoint           = aws_db_instance.main.address
    db_port               = tostring(aws_db_instance.main.port)
    db_name               = aws_db_instance.main.db_name
    rds_security_group_id = aws_security_group.rds.id
  }

  # Fase 4 (spec 12 §1), lidos pelos deploys do Billing e do Execution. Sem credenciais, como acima.
  ssm_contract_services = {
    "billing/db_endpoint"      = aws_db_instance.billing.address
    "billing/db_port"          = tostring(aws_db_instance.billing.port)
    "billing/db_name"          = aws_db_instance.billing.db_name
    "execution/dynamodb_table" = aws_dynamodb_table.execution.name
  }
}

resource "aws_ssm_parameter" "contract" {
  for_each = merge(local.ssm_contract, local.ssm_contract_services)

  name  = "/${var.project_name}/${local.env}/${each.key}"
  type  = "String"
  value = each.value
}
