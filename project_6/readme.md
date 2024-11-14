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
- **Oauth**: Manages the lifecycle of the containerized application. ECS orchestrates the deployment, scaling, and management of container instances.
- **Docker Hub (Upstream)**: The source for container images. The pull-through cache retrieves and stores images from Docker Hub on demand.
- **VPC (Virtual Private Cloud)**: Provides a secure network for ECS and ECR. ECS tasks run within private subnets, with necessary security group rules for inbound/outbound access.
- **Serverless**: For deployment container on compute instance which two instance types are EC2 and Fargate(serverless). In this process, use serverless instance(Fargate).

## Implementation
- **Create secret manager**
  - Create secret to connect with Docker by using dynamically token rotating.
- **IAM policy to user**:
  - Attach policy *AmazonEC2ContainerRegistryFullAccess* to user who can pull images from docker hub to ECR registry.
- **ECR pull-through-cache feature**
  - Create an ECR repository with a pull-through cache rule, adding a new rule for specifying Docker Hub as the upstream.
  - Configure ECR permissions to allow ECS access for pulling images.
- **Pull image from upstream registry**:
  - Pull image from docker hub by aws cli as ECR provided pull commands.
- **Deploy web service on ECS**:
  - Create ECS cluster and defined instance type
  - Create task definition and configure container specifications.
  - Add ECS service under ECS cluster.
## Verification
- Go to task under ECS cluster >> public ip
- Access public ip on your web browser
  ![2024-11-06_17-44](https://github.com/user-attachments/assets/d341779e-2773-4603-86b3-06ac84b3775b)
  
## Clean up
- Destroy your created aws resources to save money.
## Reference
