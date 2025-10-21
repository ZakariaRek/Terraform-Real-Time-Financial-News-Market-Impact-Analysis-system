# backend-configs/backendprod.tf
# S3 Backend Configuration for Production Environment
# This file configures remote state storage in S3 with DynamoDB locking

bucket         = "market-impact-terraform-state-prod"
key            = "production/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "market-impact-terraform-locks-prod"

# Enable versioning for state file history
versioning = true

# Server-side encryption configuration
kms_key_id = "alias/terraform-state-key"

# Tags for the S3 bucket
tags = {
  Environment = "production"
  Project     = "market-impact-analysis"
  ManagedBy   = "terraform"
  CostCenter  = "engineering"
}