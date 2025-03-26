resource "aws_iam_role" "eks-cluster-role" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-role.name
}
resource "aws_eks_cluster" "eks-cluster" {
  name = var.cluster_name
  role_arn = aws_iam_role.eks-cluster-role.arn
  vpc_config {
    subnet_ids = [
        aws_subnet.private-subnet1.id,
        aws_subnet.private-subnet2.id,
        aws_subnet.public-subnet1.id,
        aws_subnet.public-subnet2.id
    ]
  }
  access_config {
    authentication_mode = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }
  version  = var.k8s-version
  bootstrap_self_managed_addons = true #automatically install other necessary depandencies 
  upgrade_policy {
    support_type = "STANDARD"
  }
  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
  tags = {
    Name = "${var.tags}-cluster"
  }
}