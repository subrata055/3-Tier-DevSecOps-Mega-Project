# ==========================================================
# 1. Jenkins Security Group
# ==========================================================
resource "aws_security_group" "jenkins_sg" {
  name        = "${var.project_name}-jenkins-sg"
  description = "Security group for Jenkins server"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-jenkins-sg"
  }
}

# ==========================================================
# 2. SonarQube Security Group
# ==========================================================
resource "aws_security_group" "sonarqube_sg" {
  name        = "${var.project_name}-sonarqube-sg"
  description = "Security group for SonarQube server"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SonarQube UI"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sonarqube-sg"
  }
}

# ==========================================================
# 3. Dedicated ALB Security Group (Public facing)
# ==========================================================
resource "aws_security_group" "alb_sg" {
  name        = "prod-alb-sg"
  description = "Security group for Shared Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic to cluster pods/nodes"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "prod-alb-sg"
  }
}

# ==========================================================
# 4. Security Group Rules for EKS Cluster & Worker Nodes
# ==========================================================
# Allow ALB traffic into the EKS Cluster Primary/Node Security Group
resource "aws_security_group_rule" "eks_node_ingress_from_alb" {
  type                     = "ingress"
  description              = "Allow all traffic from ALB SG to EKS Nodes"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  source_security_group_id = aws_security_group.alb_sg.id
}

# Allow VPC Internal CIDR communication for pods/nodes
resource "aws_security_group_rule" "eks_node_ingress_vpc" {
  type              = "ingress"
  description       = "Allow all VPC CIDR traffic to EKS Nodes"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  cidr_blocks       = [aws_vpc.main.cidr_block]
}
