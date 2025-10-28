# environments/dev.tfvars
environment = "dev"
vpc_cidr    = "10.2.0.0/16"
region      = "us-east-1"

# EKS Configuration - SCALE UP FOR PRODUCTION-LIKE SETUP
cluster_version     = "1.30"
node_instance_types = ["t3.small"]  # 2 vCPU, 4GB RAM
node_min_size       =  15            # At least 2 nodes
node_max_size       = 17
node_desired_size   = 15         # Start with 2 nodes

# Redis Configuration
redis_node_type        = "cache.t3.micro"
redis_num_cache_nodes  = 1

# Existing RDS Configuration
existing_rds_endpoint = "postgres.curiyq4aismn.us-east-1.rds.amazonaws.com"
existing_rds_port     = "5432"
existing_rds_vpc_id   = "vpc-0e7e105568e800c58"
existing_rds_sg_id    = "sg-044567e54707e4170"