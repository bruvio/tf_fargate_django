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


