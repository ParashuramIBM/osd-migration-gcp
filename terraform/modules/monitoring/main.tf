# terraform/modules/monitoring/main.tf
resource "google_monitoring_alert_policy" "openshift_cpu" {
  display_name = "OpenShift High CPU Usage"
  combiner     = "OR"
  
  conditions {
    display_name = "High CPU Usage"
    
    condition_threshold {
      filter     = "metric.type=\"kubernetes.io/container/cpu/request_utilization\" resource.type=\"k8s_container\""
      duration   = "300s"
      comparison = "COMPARISON_GT"
      threshold_value = 0.8
      
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }
  
  notification_channels = var.notification_channels
}