# TFE  
output "tfe" {
  value = "https://${aws_route53_record.alias_record.fqdn}/admin/account/new?token=${random_id.user_token.hex}"
}
