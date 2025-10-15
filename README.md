# Market Impact Analysis System - Terraform Infrastructure

This repository contains the Terraform infrastructure code for the Market Impact Analysis System.

## Project Structure
```
terraform/
├── environments/       # Environment-specific configurations
│   ├── production/
│   ├── staging/
│   └── development/
├── modules/           # Reusable Terraform modules
│   ├── vpc/
│   ├── eks/
│   ├── rds/
│   ├── elasticache/
│   ├── secrets-manager/
│   ├── ecr/
│   ├── s3/
│   ├── cloudwatch/
│   ├── iam/
│   ├── route53/
│   ├── acm/
│   ├── alb/
│   └── monitoring/
├── global/            # Global resources
│   ├── terraform-state/
│   └── iam-roles/
├── scripts/           # Helper scripts
└── docs/             # Documentation
```

## Quick Start

### Prerequisites

- Terraform >= 1.5.0
- AWS CLI configured
- Valid AWS credentials

### Initialize Backend
```powershell
cd environments/production
terraform init
```

### Plan Changes
```powershell
terraform plan -out=tfplan
```

### Apply Changes
```powershell
terraform apply tfplan
```

## Documentation

- [Architecture](docs/architecture.md)
- [Deployment Guide](docs/deployment-guide.md)
- [Runbook](docs/runbook.md)
- [Cost Estimation](docs/cost-estimation.md)
- [Disaster Recovery](docs/disaster-recovery.md)

## Environments

### Production
- **Region**: us-east-1
- **VPC CIDR**: 10.0.0.0/16
- **High Availability**: Multi-AZ deployment

### Staging
- **Region**: us-east-1
- **VPC CIDR**: 10.1.0.0/16
- **Cost Optimized**: Single-AZ with spot instances

### Development
- **Region**: us-east-1
- **VPC CIDR**: 10.2.0.0/16
- **Minimal Resources**: For testing only

## Security

- All secrets are stored in AWS Secrets Manager
- RDS and ElastiCache use encryption at rest
- Network isolation using private subnets
- IAM roles follow principle of least privilege

## Tagging Strategy

All resources are tagged with:
- Environment
- Project
- ManagedBy
- CostCenter (production only)

## Module Usage

Each module has its own README with usage examples and variable descriptions.

Example:
```hcl
module "vpc" {
  source = "../../modules/vpc"
  
  environment = "production"
  vpc_cidr    = "10.0.0.0/16"
  # ... other variables
}
```

## State Management

- State files are stored in S3
- State locking using DynamoDB
- Separate state files per environment

## Contributing

1. Create a feature branch
2. Make your changes
3. Run terraform fmt and terraform validate
4. Submit a pull request

## Support

For issues or questions, contact the Platform Engineering team.

## License

Proprietary - All Rights Reserved
