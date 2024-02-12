resource "google_compute_network" "vpc" {
    project                 = var.project_id
    name                    = var.vpc_name
    auto_create_subnetworks = false
    lifecycle {
        create_before_destroy = true
    }
}

resource "google_compute_subnetwork" "default" {
    name          = "${var.vpc_name}-subnet"
    ip_cidr_range = var.ip_cidr_range
    region        = var.region
    network       = google_compute_network.vpc.id
    lifecycle {
        create_before_destroy = true
    }
}

resource "google_vpc_access_connector" "connector" {
    name          = "connect-vpc"
    network       = google_compute_network.vpc.id
    ip_cidr_range = var.connector_ip_cidr_range
}

resource "google_compute_global_address" "private_ip_address" {
    project       = var.project_id
    name          = "private-ip"
    purpose       = "VPC_PEERING"
    address_type  = "INTERNAL"
    prefix_length = 16
    network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "default" {
    network                 = google_compute_network.vpc.id
    service                 = "servicenetworking.googleapis.com"
    reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}
