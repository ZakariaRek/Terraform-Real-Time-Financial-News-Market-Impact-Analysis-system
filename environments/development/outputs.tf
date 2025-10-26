# environments/development/outputs.tf
# Outputs for Development Environment

# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.networking.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.networking.public_subnet_ids
}

# EKS Outputs
output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = module.eks.cluster_security_group_id
}

output "eks_node_security_group_id" {
  description = "EKS node security group ID"
  value       = module.eks.node_security_group_id
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}

# Existing RDS Outputs
output "rds_endpoint" {
  description = "Existing RDS endpoint (manually created)"
  value       = var.existing_rds_endpoint
}

output "rds_port" {
  description = "Existing RDS port"
  value       = var.existing_rds_port
}

output "rds_connection_string" {
  description = "RDS connection string (password not included)"
  value       = "postgresql://<username>:<password>@${var.existing_rds_endpoint}:${var.existing_rds_port}/<database>"
}

# Redis Outputs
output "redis_endpoint" {
  description = "Redis primary endpoint"
  value       = module.elasticache.primary_endpoint_address
}

output "redis_reader_endpoint" {
  description = "Redis reader endpoint"
  value       = module.elasticache.reader_endpoint_address
}

output "redis_secret_arn" {
  description = "Redis credentials secret ARN"
  value       = module.elasticache.secret_arn
  sensitive   = true
}

# S3 Outputs
output "s3_data_lake_bucket" {
  description = "Data lake S3 bucket name"
  value       = module.s3_data_lake.bucket_name
}

# Summary Output
output "infrastructure_summary" {
  description = "Summary of deployed infrastructure"
  value = {
    environment    = var.environment
    region         = var.region
    vpc_id         = module.networking.vpc_id
    eks_cluster    = module.eks.cluster_name
    rds_endpoint   = var.existing_rds_endpoint
    redis_endpoint = module.elasticache.primary_endpoint_address
  }
}

# Security Note
output "security_note" {
  description = "Important security information"
  value       = "✅ Security group rule added to allow EKS nodes to access your existing RDS instance"
}