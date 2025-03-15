# Terraform Resource Migration
![Image](https://github.com/user-attachments/assets/791a7594-03a7-4c65-8801-757c7b38db6b)
### This terraform command use to import the terraform config when someone manually modified the resources.
- terraform import (native tf) - Need to write terraform configuration
- Azure IF export - No need to write terraform configuration
- Terraformer (Open-source) - No need to write terraform configuration

## Terraform Import
![Image](https://github.com/user-attachments/assets/5831ae88-1d4b-4d11-9392-0721b0a0afa4)
- Manually create resources(consider live environment)
- Write terraform files
```bash
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"  
  tags = {
      Name = "test-vpc"  
      }
  }
```
- Verify the created resource by terraform
```bash
   terraform plan
```
- terraform import <resource> <resource_id>
```bash
   $ terraform import aws_vpc.main vpc-0af4a1e6a7218be1d
```
- check the updated terraform resources
```bash
   $ terraform state list
aws_vpc.main

$ terraform state show aws_vpc.main
# aws_vpc.main:
resource "aws_vpc" "main" {
```
