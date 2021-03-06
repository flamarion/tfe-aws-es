# Random Pet
resource "random_password" "redis_password" {
  length  = 16
  special = false
}

# Redis Cluster
resource "aws_elasticache_replication_group" "redis_cluster" {
  node_type                     = "cache.m4.large"
  replication_group_id          = "${var.owner}-tfe-es-redis"
  replication_group_description = "${var.owner}-tfe-es-redis"
  apply_immediately             = true
  at_rest_encryption_enabled    = true
  auth_token                    = random_password.redis_password.result
  automatic_failover_enabled    = true
  availability_zones            = data.terraform_remote_state.vpc.outputs.az
  engine                        = "redis"
  engine_version                = "5.0.6"
  number_cache_clusters         = length(data.terraform_remote_state.vpc.outputs.az)
  parameter_group_name          = "default.redis5.0"
  port                          = var.redis_port
  security_group_ids            = [module.redis_sg.sg_id]
  subnet_group_name             = data.terraform_remote_state.vpc.outputs.cache_subnet_group[0]
  transit_encryption_enabled    = true
  tags = {
    "Name" = "${var.owner}-tfe-es-redis"
  }
}
