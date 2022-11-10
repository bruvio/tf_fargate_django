
resource "aws_iam_user" "user-proxy" {
  name = "${var.project}-proxy"
}

resource "aws_iam_access_key" "access-key-proxy" {
  user = aws_iam_user.user-proxy.name
}


resource "aws_iam_user" "user" {
  name = var.project
}

resource "aws_iam_access_key" "access-key" {
  user = aws_iam_user.user.name
}

resource "aws_iam_user_policy_attachment" "attach-user" {
  user       = aws_iam_user.user.name
  policy_arn = aws_iam_policy.AppApiCi-proxy.arn
}

resource "aws_iam_user_policy_attachment" "attach-user" {
  user       = aws_iam_user.user.name
  policy_arn = aws_iam_policy.AppApiCi.arn
}


resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "${var.project}-${var.bastion_key_name}" # Create "myKey" to AWS!!var.bastion_key_name
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" { # Create "myKey.pem" to your computer!!
    command = "echo '${tls_private_key.pk.private_key_pem}' > ./${var.project}-myKey.pem"
  }
}

resource "aws_iam_policy" "AppApiCi-proxy" {
  name = "${var.project}-AppApi-CI-proxy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:*"
        ],
        "Resource" : "arn:aws:ecr:us-east-1:*:repository/${var.ecr_image_api}"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetAuthorizationToken"
        ],
        "Resource" : "*"
      }
   ]
    }
  )
  tags = var.common_tags
}    
resource "aws_iam_policy" "AppApiCi" {
  name = "${var.project}-AppApi-CI"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:*"
        ],
        "Resource" : "arn:aws:ecr:us-east-1:*:repository/${var.ecr_image_api}"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetAuthorizationToken"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "TerraformRequiredPermissions1",
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ec2:*"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowListS3StateBucket",
        "Effect" : "Allow",
        "Action" : "s3:ListBucket",
        "Resource" : "arn:aws:s3:::${var.bucket_name}"
      },
      {
        "Sid" : "AllowS3StateBucketAccess",
        "Effect" : "Allow",
        "Action" : ["s3:GetObject", "s3:PutObject"],
        "Resource" : "arn:aws:s3:::${var.bucket_name}/*"
      },
      {
        "Sid" : "LimitEC2Size",
        "Effect" : "Deny",
        "Action" : "ec2:RunInstances",
        "Resource" : "arn:aws:ec2:*:*:instance/*",
        "Condition" : {
          "ForAnyValue:StringNotLike" : {
            "ec2:InstanceType" : [
              "t2.micro"
            ]
          }
        }
      },
      {
        "Sid" : "AllowECRAccess",
        "Effect" : "Allow",
        "Action" : [
          "ecr:*"
        ],
        "Resource" : "arn:aws:ecr:us-east-1:*:repository/${var.ecr_image_api}"
      },
      {
        "Sid" : "AllowStateLockingAccess",
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:GetItem"
        ],
        "Resource" : [
          "arn:aws:dynamodb:*:*:table/${var.table_name}"
        ]
      },
      {
        "Sid" : "TerraformRequiredPermissions",
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ec2:*",
          "rds:DeleteDBSubnetGroup",
          "rds:CreateDBInstance",
          "rds:CreateDBSubnetGroup",
          "rds:DeleteDBInstance",
          "rds:DescribeDBSubnetGroups",
          "rds:DescribeDBInstances",
          "rds:ListTagsForResource",
          "rds:ModifyDBInstance",
          "iam:CreateServiceLinkedRole",
          "rds:AddTagsToResource",
          "iam:CreateRole",
          "iam:GetInstanceProfile",
          "iam:DeletePolicy",
          "iam:DetachRolePolicy",
          "iam:GetRole",
          "iam:AddRoleToInstanceProfile",
          "iam:ListInstanceProfilesForRole",
          "iam:ListAttachedRolePolicies",
          "iam:DeleteRole",
          "iam:TagRole",
          "iam:PassRole",
          "iam:GetPolicyVersion",
          "iam:GetPolicy",
          "iam:CreatePolicyVersion",
          "iam:DeletePolicyVersion",
          "iam:CreateInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:ListPolicyVersions",
          "iam:AttachRolePolicy",
          "iam:CreatePolicy",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:ListRolePolicies",
          "logs:CreateLogGroup",
          "logs:DeleteLogGroup",
          "logs:DescribeLogGroups",
          "logs:ListTagsLogGroup",
          "logs:TagLogGroup",
          "ecs:DeleteCluster",
          "ecs:CreateService",
          "ecs:UpdateService",
          "ecs:DeregisterTaskDefinition",
          "ecs:DescribeClusters",
          "ecs:RegisterTaskDefinition",
          "ecs:DeleteService",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeServices",
          "ecs:CreateCluster",
          "iam:DeleteServiceLinkedRole",
          "iam:CreateServiceLinkedRole",
          "elasticloadbalancing:*",
          "s3:*",
          "acm:DeleteCertificate",
          "acm:DescribeCertificate",
          "acm:ListTagsForCertificate",
          "acm:RequestCertificate",
          "acm:AddTagsToCertificate",
          "route53:*"
        ],
        "Resource" : "*"
      }
    ]
    }
  )
  tags = var.common_tags
}



