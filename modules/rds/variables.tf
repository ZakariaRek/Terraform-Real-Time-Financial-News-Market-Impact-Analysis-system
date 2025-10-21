# modules/rds/variables.tf
# Variables for RDS Module

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "db_identifier" {
  description = "Database identifier"
  type        = string
  default     = "market-impact-db"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "database_subnet_ids" {
  description = "List of subnet IDs for database"
  type        = list(string)
}

variable "allowed_security_groups" {
  description = "List of security group IDs allowed to access the database"
  type        = list(string)
}

variable "db_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "16.3"
}

variable "db_instance_class" {
  description = "Instance class for RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_storage_type" {
  description = "Storage type (gp2, gp3, io1)"
  type        = string
  default     = "gp3"
}

variable "db_name" {
  description = "Name of the default database to create"
  type        = string
  default     = "market_impact"
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
  default     = "postgres_admin"
}

variable "db_multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "availability_zone" {
  description = "Availability zone for single-AZ deployment"
  type        = string
  default     = null
}

variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Preferred backup window (UTC)"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Preferred maintenance window (UTC)"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "delete_automated_backups" {
  description = "Delete automated backups after DB deletion"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when deleting"
  type        = bool
  default     = false
}

variable "monitoring_interval" {
  description = "Enhanced monitoring interval in seconds (0, 1, 5, 10, 15, 30, 60)"
  type        = number
  default     = 60
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = true
}

variable "auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Apply changes immediately"
  type        = bool
  default     = false
}

variable "db_parameter_group_family" {
  description = "Database parameter group family"
  type        = string
  default     = "postgres16"
}

variable "max_connections" {
  description = "Maximum number of database connections"
  type        = string
  default     = "100"
}

variable "secret_recovery_window_in_days" {
  description = "Recovery window for deleted secrets"
  type        = number
  default     = 7
}

# CloudWatch Alarm Thresholds
variable "cpu_utilization_threshold" {
  description = "CPU utilization threshold for alarm"
  type        = number
  default     = 80
}

variable "freeable_memory_threshold" {
  description = "Freeable memory threshold in bytes"
  type        = number
  default     = 536870912  # 512 MB
}

variable "free_storage_space_threshold" {
  description = "Free storage space threshold in bytes"
  type        = number
  default     = 5368709120  # 5 GB
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarm triggers"
  type        = list(string)
  default     = []
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}