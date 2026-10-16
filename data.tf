# Contrato publicado pelo oficina-infra-k8s (spec 06 §3). Nenhuma variável de rede é copiada
# à mão: se o outro repositório não foi aplicado neste workspace, o plan falha aqui com
# ParameterNotFound, apontando exatamente o que falta.
data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.project_name}/${local.env}/vpc_id"
}

data "aws_ssm_parameter" "private_subnet_ids" {
  name = "/${var.project_name}/${local.env}/private_subnet_ids"
}

data "aws_ssm_parameter" "k3s_security_group_id" {
  name = "/${var.project_name}/${local.env}/k3s_security_group_id"
}

locals {
  vpc_id                = data.aws_ssm_parameter.vpc_id.value
  private_subnet_ids    = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
  k3s_security_group_id = data.aws_ssm_parameter.k3s_security_group_id.value
}
