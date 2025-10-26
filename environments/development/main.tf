# environments/development/main.tf
# Main Terraform configuration for Development Environment
# Uses existing manually created RDS instance

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    # Backend configuration loaded from backend-configs/backenddev.tf
  }
}

# Provider Configuration
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "market-impact-analysis"
      ManagedBy   = "terraform"
    }
  }
}

# Local Variables
locals {
  cluster_name = "${var.environment}-market-impact-eks"

  common_tags = {
    Environment = var.environment
    Project     = "market-impact-analysis"
    ManagedBy   = "terraform"
  }
}

# Data source for existing RDS VPC (to configure security groups)
data "aws_vpc" "existing_rds_vpc" {
  id = var.existing_rds_vpc_id
}

# VPC and Networking
module "networking" {
  source = "../../modules/Networking"

  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  region              = var.region
  cluster_name        = local.cluster_name
  enable_nat_gateway  = true  # Required for private EKS nodes
  single_nat_gateway  = true  # Single NAT for cost savings (~$32/month)
  enable_flow_logs    = false  # Disable for cost savings
  enable_vpc_endpoints = false  # Disable for cost savings
  common_tags         = local.common_tags
}

# EKS Cluster
module "eks" {
  source = "../../modules/eks"

  cluster_name                        = local.cluster_name
  cluster_version                     = var.cluster_version
  environment                         = var.environment
  vpc_id                              = module.networking.vpc_id
  private_subnet_ids                  = module.networking.private_subnet_ids
  public_subnet_ids                   = module.networking.public_subnet_ids
  cluster_endpoint_public_access      = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  # Node Group Configuration
  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  node_capacity_type  = "SPOT"  # Use SPOT instances for dev

  common_tags = local.common_tags

  depends_on = [module.networking]
}

# Security Group Rule: Allow EKS nodes to access existing RDS
# Add ingress rule to your existing RDS security group
resource "aws_security_group_rule" "rds_from_eks" {
  type                     = "ingress"
  from_port                = var.existing_rds_port
  to_port                  = var.existing_rds_port
  protocol                 = "tcp"
  source_security_group_id = module.eks.node_security_group_id
  security_group_id        = var.existing_rds_sg_id
  description              = "Allow EKS nodes to access RDS"
}

# # Optional: Allow RDS security group to receive traffic from EKS VPC CIDR
# # This is an alternative/additional rule if the above doesn't work
# resource "aws_security_group_rule" "rds_from_eks_cidr" {
#   type              = "ingress"
#   from_port         = var.existing_rds_port
#   to_port           = var.existing_rds_port
#   protocol          = "tcp"
#   cidr_blocks       = [var.vpc_cidr]
#   security_group_id = var.existing_rds_sg_id
#   description       = "Allow EKS VPC CIDR to access RDS"
# }

# ElastiCache Redis
module "elasticache" {
  source = "../../modules/ElastiCache"

  environment             = var.environment
  vpc_id                  = module.networking.vpc_id
  private_subnet_ids      = module.networking.private_subnet_ids
  allowed_security_groups = [module.eks.node_security_group_id]

  # Redis Configuration
  redis_version           = "7.1"
  redis_node_type         = var.redis_node_type
  redis_num_cache_nodes   = var.redis_num_cache_nodes
  multi_az_enabled        = false
  transit_encryption_enabled = false

  # Maintenance
  maintenance_window       = "sun:05:00-sun:06:00"
  snapshot_window          = "03:00-04:00"
  snapshot_retention_limit = 1  # Minimal retention for dev

  common_tags = local.common_tags

  depends_on = [module.networking, module.eks]
}

# S3 Bucket for Data Lake
module "s3_data_lake" {
  source = "../../modules/s3"

  environment    = var.environment
  bucket_name    = "${var.environment}-market-impact-data-lake-${data.aws_caller_identity.current.account_id}"
  bucket_purpose = "data-lake"

  versioning_enabled       = false  # Disabled for dev
  lifecycle_rules_enabled  = true
  logging_enabled          = false
  cors_enabled             = false
  notifications_enabled    = false
  size_monitoring_enabled  = false

  eks_node_role_arn = module.eks.node_role_arn

  common_tags = local.common_tags

  depends_on = [module.eks]
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}

# Store existing RDS connection details in SSM Parameter Store
# This makes it easier to reference in your application
resource "aws_ssm_parameter" "rds_endpoint" {
  name        = "/${var.environment}/rds/endpoint"
  description = "Existing RDS endpoint"
  type        = "String"
  value       = var.existing_rds_endpoint

  tags = local.common_tags
}

resource "aws_ssm_parameter" "rds_port" {
  name        = "/${var.environment}/rds/port"
  description = "Existing RDS port"
  type        = "String"
  value       = var.existing_rds_port

  tags = local.common_tags
}