# AWS Region & Project Details
aws_region   = "us-east-1"
project_name = "devsecops-prod"
key_name     = "3-Tier-DevSecOps"

# Server Deployment Toggles (true = create, false = skip)
enable_jenkins   = true
enable_sonarqube = true

# EKS Cluster Configurations
eks_version          = "1.34"
node_capacity_type   = "SPOT" # Options: "SPOT" or "ON_DEMAND"
node_instance_type   = "t3.medium"
node_desired_size    = 2
node_min_size        = 1
node_max_size        = 2
node_disk_size_gb    = 30
