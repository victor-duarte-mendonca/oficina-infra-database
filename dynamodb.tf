# Tabela unica do Execution Service (Fase 4, spec 02 §4 e spec 06). Mesma definicao de ExecutionTable.createIfMissing
# (oficina-execution-service): chaves pk/sk, GSI1 (fila ordenada por fase) e GSI2 (outbox pendente, indice esparso),
# TTL no atributo "ttl" (inbox de 7 dias). Em AWS o servico NAO cria a tabela (DYNAMODB_CREATE_TABLE=false).
resource "aws_dynamodb_table" "execution" {
  name         = "${local.name_prefix}-execution"
  billing_mode = "PAY_PER_REQUEST" # sem capacidade provisionada: custo desprezivel e sem throttling no laboratorio
  hash_key     = "pk"
  range_key    = "sk"

  attribute {
    name = "pk"
    type = "S"
  }
  attribute {
    name = "sk"
    type = "S"
  }
  attribute {
    name = "gsi1pk"
    type = "S"
  }
  attribute {
    name = "gsi1sk"
    type = "S"
  }
  attribute {
    name = "gsi2pk"
    type = "S"
  }
  attribute {
    name = "gsi2sk"
    type = "S"
  }

  global_secondary_index {
    name            = "gsi1"
    hash_key        = "gsi1pk"
    range_key       = "gsi1sk"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "gsi2"
    hash_key        = "gsi2pk"
    range_key       = "gsi2sk"
    projection_type = "ALL"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  # Criptografia em repouso com a chave gerenciada padrao do servico (sem custo). Sem PITR: a tabela e recriada a
  # cada sessao do laboratorio.
  server_side_encryption {
    enabled = true
  }

  tags = { Name = "${local.name_prefix}-execution" }
}
