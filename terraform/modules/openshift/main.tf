terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
}

# Note: OpenShift Dedicated on GCP is deployed through Google Cloud Marketplace
# This requires manual subscription through the GCP Console or using gcloud CLI
# Terraform doesn't have direct support for OSD cluster creation on GCP
# 
# Alternative approaches:
# 1. Use Red Hat Cloud Services API (requires API token)
# 2. Use OCM (OpenShift Cluster Manager) CLI wrapped in null_resource
# 3. Manual deployment through GCP Marketplace + import to Terraform

# Placeholder for OSD cluster - requires manual deployment or API integration
resource "null_resource" "osd_cluster_placeholder" {
  triggers = {
    cluster_name = var.cluster_name
    region       = var.cloud_region
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "OpenShift Dedicated cluster deployment on GCP requires:"
      echo "1. Subscribe to OSD in GCP Marketplace"
      echo "2. Use Red Hat Cloud Services API or OCM CLI"
      echo "3. Cluster Name: ${var.cluster_name}"
      echo "4. Region: ${var.cloud_region}"
      echo "5. Network: ${var.network_name}"
      echo "6. Subnet: ${var.subnet_ids[0]}"
    EOT
  }
}

# If using Red Hat OCM API, you would use something like:
# This is a conceptual example - actual implementation depends on your setup

data "external" "cluster_info" {
  program = ["bash", "-c", <<-EOT
    # This would call OCM API or CLI to get cluster info
    # For now, return placeholder data
    echo '{"cluster_id":"placeholder","api_url":"https://api.placeholder.com","console_url":"https://console.placeholder.com"}'
  EOT
  ]
  
  depends_on = [null_resource.osd_cluster_placeholder]
}

output "cluster_id" {
  value       = data.external.cluster_info.result.cluster_id
  description = "OpenShift cluster ID"
}

output "api_url" {
  value       = data.external.cluster_info.result.api_url
  description = "OpenShift API URL"
}

output "console_url" {
  value       = data.external.cluster_info.result.console_url
  description = "OpenShift Console URL"
}

output "kubeconfig" {
  value       = "# Kubeconfig must be obtained from OpenShift Console or OCM CLI"
  sensitive   = true
  description = "Placeholder for kubeconfig"
}

output "cluster_credentials" {
  value = jsonencode({
    username = "kubeadmin"
    password = "# Password must be obtained from OpenShift Console"
  })
  sensitive   = true
  description = "Placeholder for cluster credentials"
}