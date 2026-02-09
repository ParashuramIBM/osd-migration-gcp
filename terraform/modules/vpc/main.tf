resource "google_compute_network" "openshift_vpc" {
  name                    = "${var.cluster_name}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "primary_subnet" {
  name          = "${var.cluster_name}-subnet-${var.region}"
  ip_cidr_range = var.machine_cidr
  region        = var.region
  network       = google_compute_network.openshift_vpc.id
  
  private_ip_google_access = true
  
  secondary_ip_range {
    range_name    = "${var.cluster_name}-pods"
    ip_cidr_range = var.pod_cidr
  }
  
  secondary_ip_range {
    range_name    = "${var.cluster_name}-services"
    ip_cidr_range = var.service_cidr
  }
}

resource "google_compute_router" "router" {
  name    = "${var.cluster_name}-router"
  region  = var.region
  network = google_compute_network.openshift_vpc.id
  
  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.cluster_name}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Firewall rules for OpenShift
resource "google_compute_firewall" "openshift_internal" {
  name    = "${var.cluster_name}-internal"
  network = google_compute_network.openshift_vpc.name
  
  allow {
    protocol = "icmp"
  }
  
  allow {
    protocol = "tcp"
    ports    = ["22", "6443", "22623", "2379-2380", "9000-9999", "10250-10259", "30000-32767"]
  }
  
  allow {
    protocol = "udp"
    ports    = ["4789", "6081", "9000-9999", "30000-32767"]
  }
  
  source_ranges = [
    var.machine_cidr,
    var.pod_cidr,
    var.service_cidr,
    "10.0.0.0/8"
  ]
  
  direction = "INGRESS"
}

resource "google_compute_firewall" "openshift_external" {
  name    = "${var.cluster_name}-external"
  network = google_compute_network.openshift_vpc.name
  
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "6443"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  direction     = "INGRESS"
}

output "subnet_ids" {
  value = [google_compute_subnetwork.primary_subnet.id]
}

output "vpc_id" {
  value = google_compute_network.openshift_vpc.id
}

output "network_name" {
  value = google_compute_network.openshift_vpc.name
}

output "machine_cidr" {
  value = google_compute_subnetwork.primary_subnet.ip_cidr_range
}