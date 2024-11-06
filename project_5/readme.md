## Deploy a sample web server on ECS by using ECR pullthroughcache

![ecr_ecs drawio](https://github.com/user-attachments/assets/35014504-ecbc-42e5-8c80-99c43e76d781)

## Objective

This project demonstrates a streamlined deployment process of a web server in a containerized environment on AWS cloud.By using ECS, it runs a scalable, managed container instance in the cloud.The ECR pull-through cache reduces dependency on Docker Hub by caching images within the AWS region, minimizing latency, and ensuring a more reliable and faster deployment.

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
3. **Docker**: Docker hub account to pull public images.

## Architecture
- **AWS Secret manager** Create secret to connect with Docker hub by using access token.
- **IAM policy**: To pull image from upstream registry, the user who need to grant ECR registry permission.
- **ECR with Pull-Through Cache**: Configured to cache images from Docker Hub as an upstream registry. When ECS needs an image, it pulls from ECR rather than Docker Hub, unless the image isn’t cached, in which case it fetches it once from Docker Hub.
- **Amazon ECS**: Manages the lifecycle of the containerized application. ECS orchestrates the deployment, scaling, and management of container instances.
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
  
## Clean up
- Destroy your created aws resources to save money.
## Reference

https://pw-projects.notion.site/Deploy-a-sample-web-server-on-ECS-by-using-ECR-pullthroughcache-135cafef53ea808faf5bf47bbf883b23?pvs=4
