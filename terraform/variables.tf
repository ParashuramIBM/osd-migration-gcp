variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region for deployment"
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "Name of the OpenShift cluster"
  type        = string
  default     = "osd-gcp-cluster"
}

variable "openshift_version" {
  description = "OpenShift version"
  type        = string
  default     = "4.14"
}

variable "multi_az" {
  description = "Deploy across multiple availability zones"
  type        = bool
  default     = true
}

variable "compute_machine_type" {
  description = "Compute node machine type"
  type        = string
  default     = "n2-standard-4"
}

variable "compute_nodes_count" {
  description = "Number of compute nodes"
  type        = number
  default     = 3
}

variable "github_repo" {
  description = "GitHub repository in format 'owner/repo'"
  type        = string
}

variable "pull_secret" {
  description = "OpenShift pull secret"
  type        = string
  sensitive   = true
}

variable "rhcs_token" {
  description = "RHCS API token"
  type        = string
  sensitive   = true
}

variable "aws_account_id" {
  description = "AWS account ID (required for OSD)"
  type        = string
}