# Deploying an EKS Cluster on AWS using Terraform

### Overview
This demonstration focuses on deploying a Kubernetes cluster on AWS using Amazon Elastic Kubernetes Service (EKS), a fully managed Kubernetes service provided by AWS.

### Prerequisites
Ensure you have the following installed before proceeding:
- AWS CLI (configured with appropriate permissions)
- Terraform
- Kubectl

### Infrastructure Components
- VPC with public and private subnets
- EKS cluster with worker nodes
- IAM roles and policies for EKS
- Security groups and networking setup
- Node groups for Kubernetes workloads

### Deployment EKS
1. Initialize Terraform
```
terraform init
```
2. Plan the deployment
```
terraform plan
```
3. Apply the configuration
```
terraform apply
```
4. Configure kubectl (auto generate ~/.kube/config)
```
aws eks --region <your-region> update-kubeconfig --name <cluster-name>
```
5. Verifiy the created worker nodes
```
kubectl get nodes
```
### Destroying the Infrastructure
To remove the EKS cluster and associated resources:
```
terraform destroy --auto-approve
```