terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
    rhcs = {
      source  = "terraform-redhat/rhcs"
      version = ">= 1.1.0"
    }
  }

  backend "gcs" {
    bucket = "openshift-tf-state-bucket"  # Create this bucket first
    prefix = "terraform/state"
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

provider "rhcs" {
  token = var.rhcs_token
}

module "vpc" {
  source = "./modules/vpc"
  
  project_id    = var.gcp_project_id
  region        = var.gcp_region
  cluster_name  = var.cluster_name
}

module "workload_identity" {
  source = "./modules/workload-identity"
  
  project_id       = var.gcp_project_id
  cluster_name     = var.cluster_name
  github_repo      = var.github_repo
  service_accounts = [
    "serviceAccount:${var.gcp_project_id}.svc.id.goog[osd-cluster-1/openshift-machine-api]",
    "serviceAccount:${var.gcp_project_id}.svc.id.goog[osd-cluster-1/openshift-cloud-credential-operator]"
  ]
}

module "openshift_cluster" {
  source = "./modules/openshift"
  
  # Basic Configuration
  cluster_name           = var.cluster_name
  cloud_provider         = "gcp"
  cloud_region           = var.gcp_region
  aws_account_id         = var.aws_account_id
  
  # Network Configuration
  subnet_ids             = module.vpc.subnet_ids
  network_name           = module.vpc.network_name
  machine_cidr           = module.vpc.machine_cidr
  service_network_cidr   = "172.30.0.0/16"
  cluster_network_cidr   = "10.128.0.0/14"
  cluster_network_host_prefix = 23
  
  # Version and Properties
  openshift_version      = var.openshift_version
  private                = false  # Public cluster
  multi_az               = var.multi_az
  
  # Compute Configuration
  compute_machine_type   = var.compute_machine_type
  compute_nodes_count    = var.compute_nodes_count
  
  # GCP Configuration
  gcp_project_id         = var.gcp_project_id
  gcp_service_account    = module.workload_identity.service_account_email
  
  # Pull Secret
  pull_secret            = var.pull_secret
}

# Store cluster kubeconfig in GCS bucket
resource "google_storage_bucket_object" "kubeconfig" {
  name    = "${var.cluster_name}/kubeconfig"
  content = module.openshift_cluster.kubeconfig
  bucket  = "openshift-cluster-configs"
}

# Output cluster credentials as sensitive
resource "local_file" "cluster_credentials" {
  content  = module.openshift_cluster.cluster_credentials
  filename = "${path.module}/cluster_credentials.json"
}