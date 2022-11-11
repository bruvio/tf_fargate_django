# tf_fargate_django
terraform module to deploy a Django app 


It will create for you:


ECR repositories: one for the app and one for the nginx proxy.

S3 buckets: one to use to store remote state and one to store public files used by the app

Core VPC infrastructure: vpc, 2 public subnets, 2 private subnets, internet gateway, loadbalancer, target groups.

DynamoDB table to store lock state

Route53 CNAME for your load balancer using a ACM certificate (for now hardcoded)

EC2 bastion host with docker to ssh and connect to the RDS database for managment operations.

IAM users (2) to operate with right permission and key pair to ssh into the bastion host

ECS FARGATE cluster





At the momment the logic is the following:
the user can deploy Terraform from the terminal using a role with the right permissions. Once deployed in the project folder will find two keys and in the terraform outputs AWS credentials for two roles: proxy and user. The user`proxy` has permission to just push an image to ECR. the user `user` has more permissions to interact with AWS.

This is due to the fact that I envisage using these credentials in Gitlab CI as secrets and later allow the deployment using the Gitlab CI.

The key in the project folder can be used to ssh into the bastion host to operate managment operations.


------
The module still needs further development, feel free to contribute.
