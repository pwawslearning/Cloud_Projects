## Deploy AWS infrastructure resources by using terraform cloud VCS driven workflow

![diagram](https://github.com/user-attachments/assets/56262507-2776-4647-b9a9-48516a7f9afd)

## Objective

This project demonstrates to understand the Terraform VCS driven workflow which is one feature of Terraform Cloud under Hashicorp Cloud Platform and is working like as CICD pipeline.

This is GitOps architecture to deploy AWS resources continuous integration and continuous deployment with terraform cloud when codes updated on Github registry.

By using VCS driven workflow, terraform statefiles will be automatically saving in terraform cloud and we don’t need to run terraform commands and won’t save terraform statefiles in local machine.

## 📋 Table of Contents
1. [Prerequisites](#prerequisites)
2. [Architecture](#architecture)
3. [Implementation](#implementation)
4. [Verification](#verification)
5. [Reference](#reference)

---

## Prerequisites

Before getting started, ensure you have the following:

1. **AWS account**: For deployment ECS and ECR on AWS cloud.
2. **Install awscli and secret_key & access_key**: securely connect to AWS resources.
3. **Terraform**: Install Terraform updated version.
4. **HCP account**: Create Hashicorp Cloud Platform account to access Terraform Cloud.
5. **GitHub**: Store Terraform codes and Integrate to Terraform cloud.

## Architecture
- **GitOps** Automating infrastructure provisioning by using infrastructure as code.
- **HCP**: Hashicorp provides the services to integrate with multi-cloud environment such as Vagrant, Consul, Terraform, Vault, etc.
- **Terraform Cloud**: Store terraform statefile and able to check the version history of the code changing.
- **OAuth**: Identify authentication to integrate between Version Control providers and Terraform Cloud.
- **Terraform Workspace**: it mostly store terraform statefiles and manipulate RUN/PLAN/DELETE terraform codes.
  
## Implementation
- **Create Github Registry**
  - To store terraform codes.
- **Create project and workspace**:
  - Define project name and workspace for specific project and define workflow in workspace.
  - Manage terraform state files.
- **Integrate between Terraform cloud and Version Control Provider**
  - Set up authentication with Github under Developer setting and generate Client ID and secrets.
- **Set Variable for AWS access_key and secret_key**
  - Set variables to access AWS account with user identity.
    https://docs.aws.amazon.com/cli/v1/userguide/cli-configure-envvars.html
- **Deploy AWS resources**:
  - Create AWS resources by using terraform.
  - If using *auto-apply* feature, only need to commit codes in Github.
  - Auto trigger between Github and Terraform cloud and deploy AWS resources.
## Verification
- Check the created AWS resources such as VPC, subnets, route tables, ECS, etc.
- Browse public ip address of the created EC2.
  
## Clean up
- Delete Terraform workspace.
## Reference

https://pw-projects.notion.site/Deploy-AWS-infrastructure-resources-by-using-Terraform-with-VCS-driven-workflow-136cafef53ea80b2b2dcdcab477a10bd?pvs=4

---
