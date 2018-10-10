# EKS 101
1. [Create Cloud9 Environment](#create-cloud9-environment)
2. [Create Admin Role for Cloud9 Environment](#create-role)
3. [Attach Role to Cloud9 Environment](#attach-role-to-cloud9-environment)

## Create Cloud9 Environment
Click the link below to create a Cloud9 console environment

[Cloud9](https://us-west-2.console.aws.amazon.com/cloud9/home?region=us-west-2)

## Create Role
Click the link below to create an Instance Profile to Attach to your Cloud9 Environment

[AWS IAM](https://console.aws.amazon.com/iam/home#/roles$new?step=review&commonUseCase=EC2%2BEC2&selectedUseCase=EC2&policies=arn:aws:iam::aws:policy%2FAdministratorAccess)

## Attach role to Cloud9 Environment
[Cloud9](https://console.aws.amazon.com/ec2/v2/home?#Instances:tag:Name=*eks*;sort=desc:launchTime)
