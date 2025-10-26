# environments/dev.tfvars
# FREE TIER OPTIMIZED - Using Your Existing RDS
# Estimated cost: ~$104/month (no RDS cost!)

environment = "dev"
vpc_cidr    = "10.2.0.0/16"
region      = "us-east-1"

# EKS Configuration
cluster_version     = "1.30"
node_instance_types = ["t3.micro"]  # FREE TIER: 2 vCPU, 1GB RAM
node_min_size       = 1
node_max_size       = 2
node_desired_size   = 1

# Redis Configuration
redis_node_type        = "cache.t3.micro"  # ~$12/month
redis_num_cache_nodes  = 1

# Existing RDS Configuration (Manual)
# RDS is in a different VPC but publicly accessible
existing_rds_endpoint = "postgres.curiyq4aismn.us-east-1.rds.amazonaws.com"
existing_rds_port     = "5432"
existing_rds_vpc_id   = "vpc-0e7e105568e800c58"
existing_rds_sg_id    = "sg-044567e54707e4170"