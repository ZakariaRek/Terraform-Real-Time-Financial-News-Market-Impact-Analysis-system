# backend-configs/backenddev.tf
# S3 Backend Configuration for Development Environment

bucket         = "market-impact-terraform-state-dev"
key            = "development/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "market-impact-terraform-locks-dev"
versioning     = true

tags = {
  Environment = "development"
  Project     = "market-impact-analysis"
  ManagedBy   = "terraform"
}