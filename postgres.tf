resource "random_password" "db_pw" {
  length  = 8
  special = false
}

# RDS Postgre Cluster module

module "pgsql_cluster" {
  source                 = "github.com/flamarion/terraform-aws-rds?ref=v0.0.4"
  apply_immediately      = true
  availability_zones     = data.terraform_remote_state.vpc.outputs.az
  cluster_identifier     = "${var.owner}-tfe-es-pgsql"
  database_name          = "tfe"
  db_subnet_group_name   = data.terraform_remote_state.vpc.outputs.database_subnet_group[0]
  engine                 = "aurora-postgresql"
  master_password        = random_password.db_pw.result
  master_username        = "tfe"
  skip_final_snapshot    = true
  vpc_security_group_ids = [module.db_sg.sg_id]
  replica_count          = 2
  identifier             = "${var.owner}-tfe-db-instance"
  instance_class         = "db.t3.medium"
  db_tags = {
    "Name" = "${var.owner}-tfe-es-pgsql"
  }
}
