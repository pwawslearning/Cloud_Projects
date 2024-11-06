## Deploy a sample web server on ECS by using ECR pullthroughcache

![ecr_ecs drawio](https://github.com/user-attachments/assets/35014504-ecbc-42e5-8c80-99c43e76d781)

## Objective

This project demonstrates a streamlined deployment process of a web server in a containerized environment on AWS cloud.By using ECS, it runs a scalable, managed container instance in the cloud.The ECR pull-through cache reduces dependency on Docker Hub by caching images within the AWS region, minimizing latency, and ensuring a more reliable and faster deployment.

## 📋 Table of Contents
1. [Prerequisites](#prerequisites)
2. [Project Structure](#project-structure)
3. [Tech Stack](#tech-stack)
4. [Getting Started](#getting-started)

---

## Prerequisites

Before getting started, ensure you have the following:

1. **AWS account**: For deployment ECS and ECR on AWS cloud.
2. **Install awscli and secret_key & access_key**: securely connect to AWS resources.
3. **Docker**: Docker hub account to pull public images.
