variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
  default     = "devsecops-prod"
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
  default     = "3-Tier-DevSecOps"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

# --- CI/CD Server Toggles ---
variable "enable_jenkins" {
  description = "Set to true to deploy Jenkins server"
  type        = bool
  default     = true
}

variable "enable_sonarqube" {
  description = "Set to true to deploy SonarQube server"
  type        = bool
  default     = true
}

# --- EKS Configurations ---
variable "eks_version" {
  description = "Kubernetes control plane version"
  type        = string
  default     = "1.30"
}

variable "node_capacity_type" {
  description = "Capacity type for EKS nodes: SPOT or ON_DEMAND"
  type        = string
  default     = "SPOT"
}

variable "node_instance_type" {
  description = "EC2 instance type for EKS nodes"
  type        = string
  default     = "t3.medium"
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 1
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 2
}

variable "node_disk_size_gb" {
  description = "Root disk size in GB for worker nodes"
  type        = number
  default     = 20
}
