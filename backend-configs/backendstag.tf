# backend-configs/backendstag.tf
# S3 Backend Configuration for Staging Environment

bucket         = "market-impact-terraform-state-staging"
key            = "staging/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "market-impact-terraform-locks-staging"
versioning     = true

tags = {
  Environment = "staging"
  Project     = "market-impact-analysis"
  ManagedBy   = "terraform"
}