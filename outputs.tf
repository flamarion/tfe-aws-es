# DB Cluster
output "db_endpoint" {
  value = module.tfe_db_cluster.endpoint
}

output "db_port" {
  value = module.tfe_db_cluster.port
}

output "db_name" {
  value = module.tfe_db_cluster.db_name
}

output "db_user" {
  value = module.tfe_db_cluster.db_user
}

output "db_pass" {
  value = module.tfe_db_cluster.db_pass
  sensitive = true
}


# Redis

output "redis_address" {
  value = aws_elasticache_replication_group.tfe.primary_endpoint_address
}

output "redis_port" {
  value = aws_elasticache_replication_group.tfe.port
}

output "redis_token" {
  value = aws_elasticache_replication_group.tfe.auth_token
}


# Storage

output "bucket_name" {
  value = split(".", aws_s3_bucket.tfe_s3.bucket_domain_name)[0]
}

output "bucket_region" {
  value = aws_s3_bucket.tfe_s3.region
}

# TFE  
output "tfe" {
  value = "https://${aws_route53_record.flamarion.fqdn}/admin/account/new?token=${random_id.user_token.hex}"
}
