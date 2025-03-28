# Deploy Apache webserver on AWS by using Terraform

![Screenshot from 2024-10-27 00-57-52](https://github.com/user-attachments/assets/d9ff2cfb-1e85-4c9d-a51f-745f0643e83c)


## Objective
This project task aims to leverage infrastructure as code (IaC) best practices to create a reusable and shareable infrastructure setup. Goal of this project to write Terraform IaC to deploy Apache Webserver in AWS cloud.

## Pre-Requisites

1. AWS IAM user access key & secret key.
2. Install Terraform IaC in your machine

## Deployment

1. Deploy the Network Infrastructure by using Terraform
   1. Create a VPC
   2. Two public subnets and two private subnets
   3. Create IGW and NAT GW.
   4. Create a public route table and two private route tables.
2. Implement security for all layers.
   1. Create security groups.
3. Create Storage
   1. Create S3 bucket to upload user-data script and save terraform statefile
4. Create compute scaling and HA
   1. Create role for IAMinstance profile
   2. Create Auto-scaling group and Application Loadbalancer
   3. Create S3 endpoint and attach to the private route tables.

## Run below terraform commands to deployment resources
 1. 'terraform init' (initialize to provider)
 2. 'terraform fmt' (check format)
 3. 'terraform validate' (validate codes)
 4. 'terraform plan' (pre-check the results before deploy)
 5. 'terraform apply' (deploy the resources)

## Validation 

  1. Login to AWS Console and verify all the resources are deployed
  2. Access the web application from public internet browser using the domain name.
     ![Apache_result](https://github.com/user-attachments/assets/493f133b-1527-4f50-bc16-4f481ec8ac86)


## Clear resources
Destroy the resources once the testing is over to save the billing by using below terraform command.

'terraform destroy'

