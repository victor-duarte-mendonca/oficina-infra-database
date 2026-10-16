output "db_identifier" {
  description = "Identificador da instância RDS (usado pelo workflow para aguardar o estado available)"
  value       = aws_db_instance.main.identifier
}

output "db_endpoint" {
  description = "Host do RDS (sem credencial)"
  value       = aws_db_instance.main.address
}

output "rds_security_group_id" {
  description = "SG do RDS; o oficina-auth-lambda cria nele a regra 5432 do seu próprio SG"
  value       = aws_security_group.rds.id
}

output "ssm_parameters" {
  description = "Parâmetros SSM publicados para os demais repositórios"
  value       = [for p in aws_ssm_parameter.contract : p.name]
}
