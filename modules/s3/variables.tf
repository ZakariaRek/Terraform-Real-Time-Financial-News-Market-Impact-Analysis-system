# modules/s3/variables.tf
# Variables for S3 Module

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "bucket_purpose" {
  description = "Purpose of the bucket (data-lake, backups, logs, etc.)"
  type        = string
  default     = "general"
}

variable "versioning_enabled" {
  description = "Enable versioning for the bucket"
  type        = bool
  default     = true
}

variable "lifecycle_rules_enabled" {
  description = "Enable lifecycle rules"
  type        = bool
  default     = true
}

variable "logging_enabled" {
  description = "Enable access logging"
  type        = bool
  default     = false
}

variable "logging_bucket" {
  description = "Target bucket for access logs"
  type        = string
  default     = null
}

variable "cors_enabled" {
  description = "Enable CORS configuration"
  type        = bool
  default     = false
}

variable "cors_allowed_origins" {
  description = "Allowed origins for CORS"
  type        = list(string)
  default     = ["*"]
}

variable "notifications_enabled" {
  description = "Enable S3 event notifications"
  type        = bool
  default     = false
}

variable "notification_topic_arn" {
  description = "SNS topic ARN for S3 notifications"
  type        = string
  default     = null
}

variable "size_monitoring_enabled" {
  description = "Enable CloudWatch alarm for bucket size"
  type        = bool
  default     = false
}

variable "size_threshold_bytes" {
  description = "Bucket size threshold for CloudWatch alarm (in bytes)"
  type        = number
  default     = 107374182400  # 100 GB
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarm triggers"
  type        = list(string)
  default     = []
}

variable "eks_node_role_arn" {
  description = "EKS node IAM role ARN for bucket access"
  type        = string
  default     = null
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}