profile         = "pw-programmatic"
vpc_cidr        = "10.0.0.0/16"
vpc_azs         = ["ap-southeast-1a", "ap-southeast-1b"]
public_subnets  = ["10.0.0.0/24", "10.0.1.0/24"]
private_subnets = ["10.0.2.0/24", "10.0.3.0/24"]
cluster_name    = "eks_cluster"