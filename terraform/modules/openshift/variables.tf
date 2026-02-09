variable "cluster_name" {
  description = "Name of the OpenShift cluster"
  type        = string
}

variable "cloud_provider" {
  description = "Cloud provider (gcp only)"
  type        = string
  default     = "gcp"
}

variable "cloud_region" {
  description = "GCP region for deployment"
  type        = string
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

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "machine_cidr" {
  description = "CIDR block for machine network"
  type        = string
}

variable "service_network_cidr" {
  description = "CIDR block for service network"
  type        = string
  default     = "172.30.0.0/16"
}

variable "cluster_network_cidr" {
  description = "CIDR block for cluster/pod network"
  type        = string
  default     = "10.128.0.0/14"
}

variable "cluster_network_host_prefix" {
  description = "Host prefix for cluster network"
  type        = number
  default     = 23
}

variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "gcp_service_account" {
  description = "GCP service account email for workload identity"
  type        = string
}

variable "pull_secret" {
  description = "OpenShift pull secret"
  type        = string
  sensitive   = true
}

variable "private" {
  description = "Whether to create a private cluster"
  type        = bool
  default     = false
}