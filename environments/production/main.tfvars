# # environments/production/main.tf
# # Main Terraform configuration for Production Environment
#
# terraform {
#   required_version = ">= 1.5.0"
#
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0"
#     }
#   }
#
#   backend "s3" {
#     # Backend configuration loaded from backend-configs/backendprod.tf
#   }
# }
#
# # Provider Configuration
# provider "aws" {
#   region = var.region
#
#   default_tags {
#     tags = {
#       Environment = var.environment
#       Project     = "market-impact-analysis"
#       ManagedBy   = "terraform"
#       CostCenter  = "engineering"
#     }
#   }
# }
#
# # Local Variables
# locals {
#   cluster_name = "${var.environment}-market-impact-eks"
#
#   common_tags = {
#     Environment = var.environment
#     Project     = "market-impact-analysis"
#     ManagedBy   = "terraform"
#     CostCenter  = "engineering"
#   }
# }
#
# # VPC and Networking
# module "networking" {
#   source = "../../modules/Networking"
#
#   environment         = var.environment
#   vpc_cidr            = var.vpc_cidr
#   region              = var.region
#   cluster_name        = local.cluster_name
#   enable_nat_gateway  = true
#   single_nat_gateway  = false  # Multi-AZ for production
#   enable_flow_logs    = true
#   enable_vpc_endpoints = true
#   common_tags         = local.common_tags
# }
#
# # EKS Cluster
# module "eks" {
#   source = "../../modules/eks"
#
#   cluster_name                        = local.cluster_name
#   cluster_version                     = var.cluster_version
#   environment                         = var.environment
#   vpc_id                              = module.networking.vpc_id
#   private_subnet_ids                  = module.networking.private_subnet_ids
#   public_subnet_ids                   = module.networking.public_subnet_ids
#   cluster_endpoint_public_access      = true
#   cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]  # Restrict in production
#
#   # Node Group Configuration
#   node_instance_types = var.node_instance_types
#   node_desired_size   = var.node_desired_size
#   node_min_size       = var.node_min_size
#   node_max_size       = var.node_max_size
#   node_capacity_type  = "ON_DEMAND"
#
#   common_tags = local.common_tags
#
#   depends_on = [module.networking]
# }
#
# # RDS PostgreSQL
# module "rds" {
#   source = "../../modules/rds"
#
#   environment            = var.environment
#   db_identifier          = "market-impact-db"
#   vpc_id                 = module.networking.vpc_id
#   database_subnet_ids    = module.networking.database_subnet_ids
#   allowed_security_groups = [module.eks.node_security_group_id]
#
#   # Database Configuration
#   db_engine_version      = "16.3"
#   db_instance_class      = var.db_instance_class
#   db_allocated_storage   = var.db_allocated_storage
#   db_storage_type        = "gp3"
#   db_name                = "market_impact"
#   db_username            = "postgres_admin"
#   db_multi_az            = var.db_multi_az
#
#   # Backup Configuration
#   backup_retention_period = 7
#   backup_window          = "03:00-04:00"
#   maintenance_window     = "sun:04:00-sun:05:00"
#   skip_final_snapshot    = false
#   deletion_protection    = true
#
#   # Monitoring
#   monitoring_interval           = 60
#   performance_insights_enabled  = true
#
#   common_tags = local.common_tags
#
#   depends_on = [module.networking, module.eks]
# }
#
# # ElastiCache Redis
# module "elasticache" {
#   source = "../../modules/ElastiCache"
#
#   environment             = var.environment
#   vpc_id                  = module.networking.vpc_id
#   private_subnet_ids      = module.networking.private_subnet_ids
#   allowed_security_groups = [module.eks.node_security_group_id]
#
#   # Redis Configuration
#   redis_version           = "7.1"
#   redis_node_type         = var.redis_node_type
#   redis_num_cache_nodes   = var.redis_num_cache_nodes
#   multi_az_enabled        = true
#   transit_encryption_enabled = false  # Set to true for production with auth token
#
#   # Maintenance
#   maintenance_window       = "sun:05:00-sun:06:00"
#   snapshot_window          = "03:00-04:00"
#   snapshot_retention_limit = 5
#
#   common_tags = local.common_tags
#
#   depends_on = [module.networking, module.eks]
# }
#
# # S3 Buckets
# module "s3_data_lake" {
#   source = "../../modules/s3"
#
#   environment    = var.environment
#   bucket_name    = "${var.environment}-market-impact-data-lake"
#   bucket_purpose = "data-lake"
#
#   versioning_enabled       = true
#   lifecycle_rules_enabled  = true
#   logging_enabled          = false
#   cors_enabled             = false
#   notifications_enabled    = false
#   size_monitoring_enabled  = true
#   size_threshold_bytes     = 107374182400  # 100 GB
#
#   eks_node_role_arn = module.eks.node_role_arn
#
#   common_tags = local.common_tags
#
#   depends_on = [module.eks]
# }
#
# module "s3_backups" {
#   source = "../../modules/s3"
#
#   environment    = var.environment
#   bucket_name    = "${var.environment}-market-impact-backups"
#   bucket_purpose = "backups"
#
#   versioning_enabled       = true
#   lifecycle_rules_enabled  = true
#   logging_enabled          = false
#   cors_enabled             = false
#   notifications_enabled    = false
#   size_monitoring_enabled  = true
#   size_threshold_bytes     = 53687091200  # 50 GB
#
#   eks_node_role_arn = module.eks.node_role_arn
#
#   common_tags = local.common_tags
#
#   depends_on = [module.eks]
# }