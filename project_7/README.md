## Deploy EKS cluster by using Terraform

![eks-cluster](https://github.com/user-attachments/assets/0fa35f2e-4f40-44be-83ae-731ad999e6ff)


## Objective

This demostration aims to understand terraform module and deployment kubernetes cluster on AWS cloud.

## 📋 Table of Contents
1. [Prerequisites](#prerequisites)
2. [Getting Started](#getting-started)

---

## Prerequisites

Before getting started, ensure you have the following:

1. **AWS account**: For deployment the network,compute,database, storage and security resources on AWS cloud.
2. **Install awscli and secret_key & access_key**: securely connect to AWS resources.
3. **Terraform**: Installed terraform
4. **kubectl**: Install kubectl client on machine

---

## 🛠 Getting Started <a name="getting-started"></a>

1. **Clone the repository**:
    ```bash
    git clone https://github.com/pwawslearning/Cloud_Projects.git
    cd Cloud_Projects/project_7
    ```

2. **Initialize Terraform Providers**:
    ```bash
    cd Terraform
    terraform init
    ```
3. **Check Terraform syntax**:
    ```bash
    terraform fmt
    terraform validate
    ```
4. **Check expected results**:
    ```bash
    terraform plan
    ```
5. **Provisioning infrastructure**:
    ```bash
    terraform apply
    ```
6. **Verify the deployment resources**:
   - *VPC*
   - *subnets*
   - *internet gateway*
   - *route-tables*
   - *nat-gateway*
   - *eks-cluster*
   - *node-group*


7. **Establish access connection to EKS cluster**:
    ```bash
    aws eks update-kubeconfig --name <cluster_name> --region <region> --profile <profile_name>
    ```
    - check the authentication for cluster access
    ```bash
    ~/.kube/config
    ```
    - Verify kubernetes default resources
    ```
    kubectl get nodes
    kubectl get pod -A
    kubeclt get namespace
    ```

8. **Cleanup**
  - To remove the created aws resources
    ```bash
    terraform destroy
    ```
