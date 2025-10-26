# environments/development/variables.tf
# Variables for Development Environment

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.30"
}

variable "node_instance_types" {
  description = "EC2 instance types for EKS nodes"
  type        = list(string)
}

variable "node_min_size" {
  description = "Minimum number of nodes"
  type        = number
}

variable "node_max_size" {
  description = "Maximum number of nodes"
  type        = number
}

variable "node_desired_size" {
  description = "Desired number of nodes"
  type        = number
}

variable "redis_node_type" {
  description = "ElastiCache node type"
  type        = string
}

variable "redis_num_cache_nodes" {
  description = "Number of cache nodes"
  type        = number
}

# Existing RDS Configuration
variable "existing_rds_endpoint" {
  description = "Endpoint of existing manually created RDS instance"
  type        = string
}

variable "existing_rds_port" {
  description = "Port of existing RDS instance"
  type        = string
  default     = "5432"
}

variable "existing_rds_vpc_id" {
  description = "VPC ID where existing RDS is located"
  type        = string
}

variable "existing_rds_sg_id" {
  description = "Security group ID of existing RDS instance"
  type        = string
}