environment = "dev"
vpc_cidr    = "10.2.0.0/16"
region      = "us-east-1"

# EKS
cluster_version     = "1.30"
node_instance_types = ["t3.medium"]
node_min_size       = 1
node_max_size       = 3
node_desired_size   = 2

# RDS
db_instance_class      = "db.t3.micro"
db_allocated_storage   = 20
db_multi_az            = false

# Redis
redis_node_type        = "cache.t3.micro"
redis_num_cache_nodes  = 1