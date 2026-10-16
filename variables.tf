variable "project_name" {
  description = "Prefixo usado no nome dos recursos"
  type        = string
  default     = "oficina"
}

variable "aws_region" {
  description = "Região AWS. Deve coincidir com a região do backend em backend.tf"
  type        = string
  default     = "us-east-1"
}

variable "db_instance_class" {
  description = "Classe da instância RDS"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_name" {
  description = "Nome do banco criado na instância"
  type        = string
  default     = "oficina_db"
}

variable "db_username" {
  description = "Usuário administrador do banco (não é segredo; a senha é)"
  type        = string
  default     = "oficina_admin"
}

variable "db_password" {
  description = "Senha do RDS — fornecer via TF_VAR_db_password (GitHub Secret DB_PASSWORD), nunca hardcoded"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 16
    error_message = "A senha do RDS deve ter ao menos 16 caracteres."
  }

  # O RDS recusa estes caracteres na senha mestre; falhar no plan é melhor que no apply.
  validation {
    condition     = can(regex("^[^/@\" ]+$", var.db_password))
    error_message = "A senha do RDS não pode conter barra, arroba, aspas duplas nem espaço."
  }
}
