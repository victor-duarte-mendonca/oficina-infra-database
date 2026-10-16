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
}

resource "aws_ssm_parameter" "contract" {
  for_each = local.ssm_contract

  name  = "/${var.project_name}/${local.env}/${each.key}"
  type  = "String"
  value = each.value
}
