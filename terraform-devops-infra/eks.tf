# Configures prod-cluster, the OIDC provider, a launch template enforcing gp3 volume types, and a Spot Instance Node Group (1 node):
# EKS Control Plane
resource "aws_eks_cluster" "main" {
  name     = "prod-cluster"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.30"

  vpc_config {
    subnet_ids              = concat(aws_subnet.public[*].id, aws_subnet.private[*].id)
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy]
}

# OIDC Provider
data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer

  tags = {
    Name = "prod-cluster-oidc-provider"
  }
}

# Launch Template to specify gp3 root volume for nodes
resource "aws_launch_template" "eks_nodes" {
  name_prefix = "prod-cluster-node-lt-"

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "prod-cluster-spot-node"
    }
  }
}

# Spot Managed Node Group (1 node)
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "prod-cluster-spot-nodes"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = aws_subnet.private[*].id

  capacity_type  = "SPOT"
  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = "$Latest"
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
  ]
}
