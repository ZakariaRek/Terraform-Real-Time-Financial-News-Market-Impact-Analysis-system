# environments/development/main.tf - SIMPLIFIED VERSION
# Based on working e-commerce setup

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

# VPC and Networking
module "networking" {
  source = "../../modules/Networking"

  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  region               = var.region
  cluster_name         = local.cluster_name
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_flow_logs     = false
  enable_vpc_endpoints = false
  common_tags          = local.common_tags
}

# EKS Cluster
module "eks" {
  source = "../../modules/eks"

  cluster_name                         = local.cluster_name
  cluster_version                      = var.cluster_version
  environment                          = var.environment
  vpc_id                               = module.networking.vpc_id
  private_subnet_ids                   = module.networking.private_subnet_ids
  public_subnet_ids                    = module.networking.public_subnet_ids
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  # Node Group Configuration
  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  node_capacity_type  = "SPOT"

  common_tags = local.common_tags

  depends_on = [module.networking]
}

# ✅ REMOVED: Cross-VPC security group rules (they don't work)
# Your RDS is already publicly accessible at:
# postgres.curiyq4aismn.us-east-1.rds.amazonaws.com:5432

# ElastiCache Redis
module "elasticache" {
  source = "../../modules/ElastiCache"

  environment             = var.environment
  vpc_id                  = module.networking.vpc_id
  private_subnet_ids      = module.networking.private_subnet_ids
  allowed_security_groups = [module.eks.node_security_group_id]

  redis_version              = "7.1"
  redis_node_type            = var.redis_node_type
  redis_num_cache_nodes      = var.redis_num_cache_nodes
  multi_az_enabled           = false
  transit_encryption_enabled = false

  maintenance_window       = "sun:05:00-sun:06:00"
  snapshot_window          = "03:00-04:00"
  snapshot_retention_limit = 1

  common_tags = local.common_tags

  depends_on = [module.networking, module.eks]
}

# S3 Bucket for Data Lake
module "s3_data_lake" {
  source = "../../modules/s3"

  environment    = var.environment
  bucket_name    = "${var.environment}-market-impact-data-lake-${data.aws_caller_identity.current.account_id}"
  bucket_purpose = "data-lake"

  versioning_enabled      = false
  lifecycle_rules_enabled = true
  logging_enabled         = false
  cors_enabled            = false
  notifications_enabled   = false
  size_monitoring_enabled = false

  eks_node_role_arn = module.eks.node_role_arn

  common_tags = local.common_tags

  depends_on = [module.eks]
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}

# Store RDS connection info in SSM (for reference only - use public endpoint)
resource "aws_ssm_parameter" "rds_endpoint" {
  name        = "/${var.environment}/rds/endpoint"
  description = "Existing RDS public endpoint"
  type        = "String"
  value       = var.existing_rds_endpoint

  tags = local.common_tags
}

resource "aws_ssm_parameter" "rds_connection_info" {
  name        = "/${var.environment}/rds/connection-info"
  description = "RDS connection information"
  type        = "String"
  value       = jsonencode({
    endpoint = var.existing_rds_endpoint
    port     = var.existing_rds_port
    note     = "This RDS is in a different VPC. Connect using public endpoint."
    connection_string = "postgresql://USERNAME:PASSWORD@${var.existing_rds_endpoint}:${var.existing_rds_port}/DATABASE_NAME"
  })

  tags = local.common_tags
}