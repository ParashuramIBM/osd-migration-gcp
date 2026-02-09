# OpenShift Dedicated (OSD) Migration to GCP

This repository contains Terraform configurations and automation scripts for deploying OpenShift Dedicated on Google Cloud Platform (GCP).

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
- [Deployment](#deployment)
- [Configuration](#configuration)
- [Modules](#modules)
- [CI/CD](#cicd)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## 🎯 Overview

This project automates the deployment of OpenShift Dedicated clusters on GCP using Terraform and GitHub Actions. It includes:

- VPC and networking configuration
- Workload Identity Federation for secure authentication
- Monitoring and alerting setup
- Automated deployment pipelines
- Multi-environment support (dev, staging, prod)

## ✅ Prerequisites

### Required Tools

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [gcloud CLI](https://cloud.google.com/sdk/docs/install)
- [Git](https://git-scm.com/downloads)
- [OpenShift CLI (oc)](https://docs.openshift.com/container-platform/latest/cli_reference/openshift_cli/getting-started-cli.html)

### Required Accounts & Access

- GCP Project with billing enabled
- Red Hat account with OpenShift subscription
- GitHub repository with Actions enabled
- AWS account (for OSD billing integration)

### Required Permissions

- GCP Project Owner or Editor role
- Ability to create service accounts and IAM bindings
- Access to GCP Marketplace

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     GCP Project                          │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │              VPC Network                          │  │
│  │  ┌────────────────────────────────────────────┐  │  │
│  │  │         OpenShift Dedicated Cluster        │  │  │
│  │  │  - Control Plane (Managed by Red Hat)      │  │  │
│  │  │  - Worker Nodes (GCP Compute)              │  │  │
│  │  │  - Monitoring & Logging                    │  │  │
│  │  └────────────────────────────────────────────┘  │  │
│  │                                                   │  │
│  │  ┌─────────────┐  ┌──────────────┐              │  │
│  │  │   Subnet    │  │  Cloud NAT   │              │  │
│  │  └─────────────┘  └──────────────┘              │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │        Workload Identity Federation              │  │
│  │  - GitHub Actions Integration                    │  │
│  │  - Service Account Bindings                      │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## 📁 Project Structure

```
.
├── .github/
│   └── workflows/
│       ├── deploy-openshift.yml    # Deployment workflow
│       └── destroy-openshift.yml   # Cleanup workflow
├── scripts/
│   ├── setup-wif.sh               # Workload Identity setup
│   └── verify-cluster.sh          # Cluster verification
├── terraform/
│   ├── main.tf                    # Root module
│   ├── variables.tf               # Root variables
│   ├── dev.tfvars                 # Dev environment config
│   ├── staging.tfvars             # Staging environment config
│   ├── prod.tfvars                # Production environment config
│   └── modules/
│       ├── vpc/                   # VPC networking module
│       ├── workload-identity/     # WIF configuration module
│       ├── openshift/             # OSD cluster module
│       └── monitoring/            # Monitoring setup module
├── .env                           # Environment variables (gitignored)
├── LICENSE
└── README.md
```

## 🚀 Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd osd-migration-gcp
```

### 2. Configure GCP Project

```bash
# Set your GCP project
export GCP_PROJECT_ID="your-project-id"
gcloud config set project $GCP_PROJECT_ID

# Enable required APIs
gcloud services enable compute.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable iamcredentials.googleapis.com
gcloud services enable sts.googleapis.com
```

### 3. Create GCS Bucket for Terraform State

```bash
gsutil mb -p $GCP_PROJECT_ID gs://openshift-tf-state-bucket
gsutil versioning set on gs://openshift-tf-state-bucket
```

### 4. Set Up Workload Identity Federation

```bash
chmod +x scripts/setup-wif.sh
./scripts/setup-wif.sh
```

### 5. Configure Environment Variables

Create a `.env` file (copy from `.env.example` if available):

```bash
# GCP Configuration
export GCP_PROJECT_ID="your-project-id"
export GCP_REGION="us-central1"

# GitHub Configuration
export GITHUB_REPO="owner/repo"

# OpenShift Configuration
export CLUSTER_NAME="osd-gcp-cluster"
export OPENSHIFT_VERSION="4.14"

# AWS Configuration (for OSD billing)
export AWS_ACCOUNT_ID="your-aws-account-id"

# Red Hat Configuration
export RHCS_TOKEN="your-rhcs-token"
export PULL_SECRET='{"auths":{"cloud.openshift.com":{"auth":"..."}}}'
```

### 6. Initialize Terraform

```bash
cd terraform
terraform init
```

## 🎯 Deployment

### Manual Deployment

#### Deploy to Development

```bash
cd terraform
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

#### Deploy to Staging

```bash
terraform plan -var-file=staging.tfvars
terraform apply -var-file=staging.tfvars
```

#### Deploy to Production

```bash
terraform plan -var-file=prod.tfvars
terraform apply -var-file=prod.tfvars
```

### Automated Deployment (GitHub Actions)

1. **Configure GitHub Secrets**:
   - `GCP_PROJECT_ID`
   - `GCP_WORKLOAD_IDENTITY_PROVIDER`
   - `GCP_SERVICE_ACCOUNT`
   - `RHCS_TOKEN`
   - `PULL_SECRET`
   - `AWS_ACCOUNT_ID`

2. **Trigger Deployment**:
   - Push to `main` branch for production
   - Push to `staging` branch for staging
   - Push to `develop` branch for development

3. **Manual Trigger**:
   - Go to Actions tab in GitHub
   - Select "Deploy OpenShift Cluster"
   - Click "Run workflow"
   - Select environment and branch

## ⚙️ Configuration

### Environment-Specific Variables

#### Development (`dev.tfvars`)
```hcl
gcp_project_id      = "dev-project-id"
gcp_region          = "us-central1"
cluster_name        = "osd-dev-cluster"
compute_nodes_count = 2
multi_az            = false
```

#### Staging (`staging.tfvars`)
```hcl
gcp_project_id      = "staging-project-id"
gcp_region          = "us-east1"
cluster_name        = "osd-staging-cluster"
compute_nodes_count = 3
multi_az            = true
```

#### Production (`prod.tfvars`)
```hcl
gcp_project_id      = "prod-project-id"
gcp_region          = "us-west1"
cluster_name        = "osd-prod-cluster"
compute_nodes_count = 5
multi_az            = true
```

### Common Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `gcp_project_id` | GCP Project ID | - | Yes |
| `gcp_region` | GCP Region | `us-central1` | No |
| `cluster_name` | OpenShift cluster name | `osd-gcp-cluster` | No |
| `openshift_version` | OpenShift version | `4.14` | No |
| `multi_az` | Multi-AZ deployment | `true` | No |
| `compute_machine_type` | Worker node machine type | `n2-standard-4` | No |
| `compute_nodes_count` | Number of worker nodes | `3` | No |
| `github_repo` | GitHub repository | - | Yes |
| `aws_account_id` | AWS account for billing | - | Yes |

## 📦 Modules

### VPC Module

Creates and configures VPC networking for OpenShift:
- VPC network with custom subnets
- Cloud NAT for outbound connectivity
- Firewall rules for OpenShift traffic
- Secondary IP ranges for pods and services

**Inputs:**
- `project_id`: GCP project ID
- `region`: GCP region
- `cluster_name`: Cluster name for resource naming
- `machine_cidr`: CIDR for machine network
- `pod_cidr`: CIDR for pod network
- `service_cidr`: CIDR for service network

**Outputs:**
- `vpc_id`: VPC network ID
- `subnet_ids`: List of subnet IDs
- `network_name`: VPC network name
- `machine_cidr`: Machine network CIDR

### Workload Identity Module

Configures Workload Identity Federation for GitHub Actions:
- Service account creation
- IAM role bindings
- Workload Identity pool and provider
- GitHub repository integration

**Inputs:**
- `project_id`: GCP project ID
- `cluster_name`: Cluster name
- `github_repo`: GitHub repository (owner/repo)
- `service_accounts`: List of service accounts to bind

**Outputs:**
- `service_account_email`: Service account email
- `workload_identity_provider`: WIF provider name

### OpenShift Module

Manages OpenShift Dedicated cluster deployment:
- Cluster configuration placeholder
- Integration with GCP Marketplace
- Credential management

**Note:** OpenShift Dedicated on GCP requires manual subscription through GCP Marketplace or Red Hat Cloud Services API.

**Inputs:**
- `cluster_name`: Cluster name
- `cloud_region`: GCP region
- `openshift_version`: OpenShift version
- `compute_nodes_count`: Number of worker nodes
- `network_name`: VPC network name
- `subnet_ids`: List of subnet IDs
- And more...

**Outputs:**
- `cluster_id`: Cluster ID
- `api_url`: API endpoint URL
- `console_url`: Console URL
- `kubeconfig`: Kubeconfig (sensitive)

### Monitoring Module

Sets up monitoring and alerting:
- Google Cloud Monitoring alerts
- CPU usage monitoring
- Notification channels

**Inputs:**
- `notification_channels`: List of notification channel IDs

## 🔄 CI/CD

### GitHub Actions Workflows

#### Deploy Workflow (`.github/workflows/deploy-openshift.yml`)

Triggers on:
- Push to `main`, `staging`, or `develop` branches
- Manual workflow dispatch

Steps:
1. Authenticate with GCP using Workload Identity
2. Initialize Terraform
3. Plan infrastructure changes
4. Apply changes (with approval for production)
5. Verify cluster deployment

#### Destroy Workflow (`.github/workflows/destroy-openshift.yml`)

Triggers on:
- Manual workflow dispatch only

Steps:
1. Authenticate with GCP
2. Initialize Terraform
3. Plan destruction
4. Destroy infrastructure (requires approval)

### Workflow Secrets

Configure these secrets in GitHub repository settings:

```
GCP_PROJECT_ID              # GCP project ID
GCP_WORKLOAD_IDENTITY_PROVIDER  # WIF provider name
GCP_SERVICE_ACCOUNT         # Service account email
RHCS_TOKEN                  # Red Hat Cloud Services token
PULL_SECRET                 # OpenShift pull secret
AWS_ACCOUNT_ID              # AWS account for billing
```

## 🔍 Troubleshooting

### Common Issues

#### 1. Terraform State Lock

```bash
# Remove state lock (use with caution)
terraform force-unlock <lock-id>
```

#### 2. Authentication Errors

```bash
# Re-authenticate with GCP
gcloud auth application-default login
gcloud auth login
```

#### 3. Provider Version Conflicts

```bash
# Upgrade providers
terraform init -upgrade
```

#### 4. OpenShift Cluster Not Accessible

```bash
# Verify cluster status
./scripts/verify-cluster.sh

# Check firewall rules
gcloud compute firewall-rules list --filter="network:osd-gcp-cluster-vpc"
```

### Validation Commands

```bash
# Validate Terraform configuration
terraform validate

# Format Terraform files
terraform fmt -recursive

# Check Terraform plan
terraform plan -var-file=dev.tfvars

# Verify GCP resources
gcloud compute networks list
gcloud compute subnetworks list
gcloud iam service-accounts list
```

### Logs and Debugging

```bash
# Enable Terraform debug logging
export TF_LOG=DEBUG
export TF_LOG_PATH=./terraform-debug.log

# View GitHub Actions logs
# Go to Actions tab in GitHub repository

# Check GCP Cloud Logging
gcloud logging read "resource.type=gce_instance" --limit 50
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow Terraform best practices
- Use meaningful variable and resource names
- Add comments for complex logic
- Update documentation for any changes
- Test changes in dev environment first
- Run `terraform fmt` before committing

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For issues and questions:
- Open an issue in GitHub
- Contact the DevOps team
- Check Red Hat OpenShift documentation

## 🔗 Useful Links

- [OpenShift Documentation](https://docs.openshift.com/)
- [GCP Documentation](https://cloud.google.com/docs)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Red Hat Cloud Services](https://console.redhat.com/)
- [OpenShift on GCP Marketplace](https://console.cloud.google.com/marketplace/product/redhat-marketplace-public/openshift-dedicated)

## ⚠️ Important Notes

1. **OpenShift Dedicated Deployment**: This implementation provides infrastructure setup. Actual OSD cluster deployment requires:
   - Subscription through GCP Marketplace
   - Red Hat Cloud Services API integration
   - Manual cluster creation through OpenShift Console

2. **Cost Considerations**: 
   - OpenShift Dedicated has hourly charges
   - GCP resources (VPC, NAT, Compute) incur costs
   - Monitor usage in GCP Billing console

3. **Security**:
   - Never commit sensitive data (tokens, secrets) to Git
   - Use GitHub Secrets for CI/CD credentials
   - Rotate service account keys regularly
   - Enable audit logging

4. **Backup and Disaster Recovery**:
   - Terraform state is stored in GCS with versioning
   - Regular backups of cluster data recommended
   - Document recovery procedures

---

**Last Updated**: 2026-02-09
**Version**: 1.0.0