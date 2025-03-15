# Advanced Azure Infrastructure with Terraform

![Image](https://github.com/user-attachments/assets/a4875083-fe87-482f-8826-2f929694805a)

## Project Overview
I will create a scalable web application infrastructure in Azure using Terraform. The infrastructure will include a Virtual Machine Scale Set (VMSS) behind a load balancer with proper security and scaling configurations.

## Requirements

### Base Infrastructure
1. Create a resource group in one of these regions:
   - Canada Central
   - West Europe
   - Southeast Asia

### Networking
1. Create a VNet with two subnets:
   - Application subnet (for VMSS)
   - Management subnet (for future use)
2. Configure an NSG that:
   - Only allows traffic from the load balancer to VMSS
   - Uses dynamic blocks for rule configuration
   - Denies all other inbound traffic

### Compute
1. Set up a VMSS with:
   - Ubuntu 20.04 LTS
   - VM sizes with conditions based on environment:
     * Dev: Standard_B1s
     * Stage: Standard_B2s
     * Prod: Standard_B2ms
2. Configure auto-scaling:
   - Scale in when CPU < 10%
   - Scale out when CPU > 80%
   - Minimum instances: 3
   - Maximum instances: 5

### Load Balancer
1. Create an Azure Load Balancer:
   - Public IP
   - Backend pool connected to VMSS
   - Health probe on port 80

## Technical Requirements

### Variables
1. Create a terraform.tfvars file with:
   - Environment name
   - Region
   - Resource name prefix
   - Instance counts
   - Network address spaces

### Dynamic Blocks
1. Use dynamic blocks for:
   - NSG rules
   - Load balancer rules

### Resoruces
![Image](https://github.com/user-attachments/assets/dda1cc24-d1d3-463a-bf00-c5f7affba044)

### Testing
![Image](https://github.com/user-attachments/assets/f967c339-5eb6-4b3b-86f7-ec2168f3e476)
