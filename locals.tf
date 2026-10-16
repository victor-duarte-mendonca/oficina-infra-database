# Mesmos workspaces do oficina-infra-k8s. O workspace "default" é inválido de propósito:
# "terraform plan" falha com 'Invalid index' em vez de criar um banco sem ambiente definido.
locals {
  env = terraform.workspace

  environments = {
    hml = {
      backup_retention_period = 0
    }
    prod = {
      # 1 dia: backup até o tamanho do storage é gratuito, e dá alguma história de recuperação.
      backup_retention_period = 1
    }
  }

  config      = local.environments[local.env]
  name_prefix = "${var.project_name}-${local.env}"
}
