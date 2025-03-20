
# Build peer connection between two VPCs by using Terraform

![Image](https://github.com/user-attachments/assets/47b5dee8-5a9b-400e-884b-c2a9b4a40158)

VPC Peering allows direct network communication between two VPCs in AWS. This demostration aims to set up VPC Peering between two VPCs in different AWS regions by using Terraform configuration.

## Prerequisites 
- Terraform install
- AWS CLI configured
- IAM permission to create VPC, subnet, route table and peering connections

## Architecture
- VPC-1 (ap-southeast-1) → 10.0.0.0/24
- VPC-2 (ap-southeast-2) → 192.168.0.0/24
- Peering Connection between both VPCs
- Route Tables updated for cross-VPC communication
- Security groups

## Terraform configuration
1. Define providers and regions
```provider "aws" {
  profile = "test-cli"
  region  = "ap-southeast-1"
}
provider "aws" {
  profile = "test-cli"
  region  = "ap-southeast-1"
  alias   = "ap-southeast-1"
}
provider "aws" {
  profile = "test-cli"
  region  = "ap-southeast-2"
  alias   = "ap-southeast-2"
}
```
2. Create VPCs
```
resource "aws_vpc" "vpc1" {
  cidr_block       = "10.0.0.0/24"
  instance_tenancy = "default"
  provider         = aws.ap-southeast-1

  tags = {
    Name = "vpc-1"
  }
}
resource "aws_vpc" "vpc2" {
  cidr_block       = "192.168.0.0/24"
  instance_tenancy = "default"
  provider         = aws.ap-southeast-2

  tags = {
    Name = "vpc-2"
  }
}

```

3. Create VPC peering connection
```
resource "aws_vpc_peering_connection" "peer1" {
  peer_vpc_id   = aws_vpc.vpc2.id
  vpc_id        = aws_vpc.vpc1.id
  auto_accept = false
  provider = aws.ap-southeast-1
  peer_region = "ap-southeast-2"

  tags = {
    Name = "vpc1_to_vpc2"
  }
}
```
4. Accept peering connection
```
resource "aws_vpc_peering_connection_accepter" "peer2" {
  provider                  = aws.ap-southeast-2
  vpc_peering_connection_id = aws_vpc_peering_connection.peer1.id
  auto_accept               = true

  tags = {
    Side = "vpc2_to_vpc1"
  }
}
```
5. Update route tables
```
resource "aws_route" "route1" {
  route_table_id = aws_route_table.vpc1-rtb.id
  destination_cidr_block = "192.168.0.0/24"
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer2.id
  provider = aws.ap-southeast-1
}
resource "aws_route" "route2" {
  route_table_id = aws_route_table.vpc2-rtb.id
  destination_cidr_block = "10.0.0.0/24"
  vpc_peering_connection_id = aws_vpc_peering_connection.peer1.id
  provider = aws.ap-southeast-2
}
```
## Deployment steps
1. Initialize Terraform
```
terraform init
```
2. Check Terraform Plan
```
terraform plan
```
3. Apply the Terraform Configuration
```
terraform apply -auto-approve
```
4. Verify the Peering Connection in AWS Console

## Testing VPC Peering

1. Launch EC2 Instances in each VPC.
2. Ping across VPCs using private IPs.
3. Ensure security groups allow ICMP and necessary ports.

## Cleanup
- To destroy all resources, run:
```
terraform destroy -auto-approve
```