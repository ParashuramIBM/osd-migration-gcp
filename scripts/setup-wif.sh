#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}=== OpenShift on GCP Setup Script ===${NC}"

# Check prerequisites
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}Error: $1 is not installed${NC}"
        exit 1
    fi
}

echo "Checking prerequisites..."
check_command gcloud
check_command terraform
check_command jq

# Set variables
read -p "Enter GCP Project ID: " GCP_PROJECT_ID
read -p "Enter GitHub Repository (owner/repo): " GITHUB_REPO
read -p "Enter Cluster Name: " CLUSTER_NAME
read -p "Enter GCP Region [us-central1]: " GCP_REGION
GCP_REGION=${GCP_REGION:-us-central1}

# Enable required APIs
echo "Enabling GCP APIs..."
gcloud services enable \
    compute.googleapis.com \
    iam.googleapis.com \
    cloudresourcemanager.googleapis.com \
    serviceusage.googleapis.com \
    storage.googleapis.com \
    --project=$GCP_PROJECT_ID

# Create Terraform state bucket
BUCKET_NAME="openshift-tf-state-$(date +%s)"
echo "Creating state bucket: $BUCKET_NAME"
gsutil mb -p $GCP_PROJECT_ID -l $GCP_REGION gs://$BUCKET_NAME/

# Create service account for initial setup
echo "Creating service account..."
gcloud iam service-accounts create terraform-admin \
    --display-name="Terraform Admin" \
    --project=$GCP_PROJECT_ID

SA_EMAIL="terraform-admin@${GCP_PROJECT_ID}.iam.gserviceaccount.com"

# Grant roles to service account
echo "Granting roles to service account..."
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/owner"

# Create and download key
echo "Creating service account key..."
gcloud iam service-accounts keys create terraform-key.json \
    --iam-account=$SA_EMAIL

# Update terraform backend configuration
echo "Updating Terraform configuration..."
cat > terraform/backend.tf << EOF
terraform {
  backend "gcs" {
    bucket = "$BUCKET_NAME"
    prefix = "terraform/state"
  }
}
EOF

# Create environment variables file
cat > .env.example << EOF
# GCP Configuration
GCP_PROJECT_ID=$GCP_PROJECT_ID
GCP_REGION=$GCP_REGION

# Cluster Configuration
CLUSTER_NAME=$CLUSTER_NAME
OPENSHIFT_VERSION=4.14
COMPUTE_NODES=3
COMPUTE_MACHINE_TYPE=n2-standard-4

# GitHub Configuration
GITHUB_REPO=$GITHUB_REPO
EOF

echo -e "${GREEN}=== Initial Setup Complete ===${NC}"
echo ""
echo "Next steps:"
echo "1. Upload terraform-key.json to GitHub Secrets as GCP_SA_KEY"
echo "2. Add other secrets to GitHub:"
echo "   - OPENSHIFT_PULL_SECRET"
echo "   - REDHAT_USERNAME"
echo "   - REDHAT_PASSWORD"
echo "3. Create environment tfvars files:"
echo "   - dev.tfvars"
echo "   - staging.tfvars"
echo "   - prod.tfvars"
echo "4. Run 'terraform init' in terraform directory"
echo "5. Trigger GitHub Actions workflow"