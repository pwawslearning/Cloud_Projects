resource "aws_iam_role" "eks-fargate-profile-role" {
  name = "eks-fargate-profile-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "fargate-execution-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.eks-fargate-profile-role.name
}
resource "aws_eks_fargate_profile" "eks-fargate-profile" {
  cluster_name           = aws_eks_cluster.eks-cluster.name
  fargate_profile_name   = "fargate-profile"
  pod_execution_role_arn = aws_iam_role.eks-fargate-profile-role.arn
  subnet_ids             = [
    aws_subnet.private-subnet1.id,
    aws_subnet.private-subnet2.id
  ]

  selector {
    namespace = "kube-system"
  }
  selector {
    namespace = "default"
  }
  depends_on = [ aws_iam_role_policy_attachment.fargate-execution-policy ]
}