# environments/staging.tfvars
# FIXED: Staging-specific values (cost-optimized)

environment = "staging"
vpc_cidr    = "10.1.0.0/16"
region      = "us-east-1"

# EKS - Smaller for staging
cluster_version     = "1.30"
node_instance_types = ["t3.medium"]
node_min_size       = 1
node_max_size       = 5
node_desired_size   = 2

# RDS - Smaller instance for staging
db_instance_class      = "db.t3.small"
db_allocated_storage   = 50
db_multi_az            = false  # Single AZ for cost savings

# Redis - Smaller for staging
redis_node_type        = "cache.t3.small"
redis_num_cache_nodes  = 1