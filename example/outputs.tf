output "db_host" {
  value = module.service_traffic.db_host
}
output "bastion_host" {
  value = module.service_traffic.bastion_host
}
output "api_endpoint" {
  value = module.service_traffic.api_endpoint
}
output "state-bucket" {
value = module.service_traffic.state-bucket 
}

output "dynamo_db_table" {
value = module.service_traffic.dynamo_db_table
}

output "ecr_image_proxy" {
  value = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.project}-proxy:latest"
}
output "ecr_image_api" {
  value = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.project}:latest"
}

output "access-key-proxy-id" {
  value = aws_iam_access_key.access-key-proxy.id
}
output "access-key-proxy-secret" {
  sensitive = true
  value = aws_iam_access_key.access-key-proxy.secret
}
output "access-key-id" {
  value = aws_iam_access_key.access-key.id
}
output "access-key-secret" {
  sensitive = true
  value = aws_iam_access_key.access-key.secret
}
