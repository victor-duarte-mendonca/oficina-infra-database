# State remoto em S3, um por workspace (hml/prod):
#   s3://<bucket>/oficina/infra-database/<workspace>/terraform.tfstate
#
# O bucket é o mesmo do oficina-infra-k8s: oficina-tfstate-<account-id>, informado em init:
#   terraform init -backend-config="bucket=$(bash scripts/bootstrap-state-bucket.sh)"
# O state guarda a senha do RDS em texto — criptografia no servidor é obrigatória e o bucket
# bloqueia acesso público (ver scripts/bootstrap-state-bucket.sh).
terraform {
  backend "s3" {
    key                  = "terraform.tfstate"
    workspace_key_prefix = "oficina/infra-database"
    region               = "us-east-1"
    use_lockfile         = true
    encrypt              = true
  }
}
