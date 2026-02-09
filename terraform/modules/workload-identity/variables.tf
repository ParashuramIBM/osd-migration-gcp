variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "cluster_name" {
  description = "Name of the OpenShift cluster"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository in format 'owner/repo'"
  type        = string
}

variable "service_accounts" {
  description = "List of service accounts to bind to workload identity"
  type        = list(string)
  default     = []
}