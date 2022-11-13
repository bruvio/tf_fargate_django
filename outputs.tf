output "db_host" {
  value = aws_db_instance.main.address
}
output "bastion_host" {
  value = aws_instance.bastion.public_dns
}
output "api_endpoint" {
  value = aws_route53_record.app.fqdn
}
output "state-bucket" {
  value = aws_s3_bucket.terraform_state.id
}

output "dynamo_db_table" {
  value = aws_dynamodb_table.terraform_lock.name
}
output "access-key-proxy-id" {
  value = aws_iam_access_key.access-key-proxy.id
}
output "access-key-proxy-secret" {
  sensitive = true
  value     = aws_iam_access_key.access-key-proxy.secret
}
output "access-key-id" {
  value = aws_iam_access_key.access-key.id
}
output "access-key-secret" {
  sensitive = true
  value     = aws_iam_access_key.access-key.secret
}

