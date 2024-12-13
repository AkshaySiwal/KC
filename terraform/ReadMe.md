# KnowledgeCity Infrastructure

This repository contains the infrastructure as code (IaC) for KnowledgeCity's AWS-based platform using Terraform.

## Architecture Overview

The infrastructure is deployed across two AWS regions:
- Primary Region: me-south-1 (Bahrain)
- DR Region: eu-central-1 (Frankfurt)

### Key Components

1. **Front-End Layer**
   - CloudFront for content delivery
   - S3 buckets for static content (React & Svelte SPAs)
   - Route 53 for DNS management
   - AWS WAF for security

2. **Application Layer**
   - EKS clusters for container orchestration
   - Application Load Balancer
   - Microservices:
     - PHP Monolithic API
     - Reporting Service
     - Media Server

3. **Database Layer**
   - RDS MySQL (Multi-AZ)
   - ClickHouse for analytics
   - ElastiCache for caching

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0.0
- kubectl
- helm



## Repository Structure

```
├── terraform/
│ ├── bootstrap/ # Initial setup (S3 backend, KMS)
│ ├── environments/ # Environment-specific configurations
│ │ ├── production/
│ │ └── staging/
│ └── modules/ # Reusable Terraform modules
│ ├── networking/ # VPC, subnets, security groups
│ ├── eks/ # EKS cluster and node groups
│ ├── rds/ # RDS instances
│ ├── clickhouse/ # ClickHouse deployment
│ ├── s3/ # S3 buckets configuration
│ ├── cloudfront/ # CDN configuration
│ ├── security/ # Security configurations
│ └── monitoring/ # Monitoring stack
├── kubernetes/ # Kubernetes manifests
│ ├── applications/ # Application deployments ( Work in Progress )
│ ├── config/ # ConfigMaps and Secrets ( Work in Progress )
│ └── monitoring/ # Monitoring configurations  ( Work in Progress )
└── ci/ # CI/CD pipeline configurations
```

## Deployment Instructions

### 1. Bootstrap Phase

```bash
cd terraform/bootstrap
terraform init
terraform apply
```

### 2. Infrastructure Deployment
```bash
cd terraform/environments/production
terraform init
terraform plan
terraform apply
```

### 3. Application Deployment

```bash
# Configure kubectl
aws eks update-kubeconfig --name production-eks --region me-south-1

# Deploy applications
kubectl apply -f kubernetes/applications/
```
