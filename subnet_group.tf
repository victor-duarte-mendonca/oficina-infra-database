resource "aws_db_subnet_group" "main" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = local.private_subnet_ids
  tags       = { Name = "${local.name_prefix}-db-subnet-group" }
}
