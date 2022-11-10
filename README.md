# tf_fargate_django
terraform module to deploy a Django app 


It will create for you:


ECR repositories: one for the app and one for the nginx proxy.

S3 buckets: one to use to store remote state and one to store public files used by the app

Core VPC infrastructure: vpc, 2 public subnets, 2 private subnets, internet gateway, loadbalancer, target groups.

DynamoDB table to store lock state

Route53 CNAME for your load balancer using a ACM certificate (for now hardcoded)

EC2 bastion host with docker to ssh and connect to the RDS database for managment operations.

IAM role to operate with right permission and key pair to ssh into the bastion host.

ECS FARGATE cluster

------
The module still needs further development, feel free to contribute.
