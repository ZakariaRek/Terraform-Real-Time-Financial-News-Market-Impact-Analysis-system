environment = "production"
vpc_cidr    = "10.0.0.0/16"
region      = "us-east-1"

# EKS
cluster_version     = "1.30"
node_instance_types = ["t3.large", "t3.xlarge"]
node_min_size       = 3
node_max_size       = 10
node_desired_size   = 5

# RDS
db_instance_class      = "db.r6g.xlarge"
db_allocated_storage   = 100
db_multi_az            = true

# Redis
redis_node_type        = "cache.r6g.large"
redis_num_cache_nodes  = 2