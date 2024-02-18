resource "google_service_account" "default" {
    account_id   = "service-account-${var.cloudrun_name}"
    display_name = "Service Account for ${var.cloudrun_name}"
}

resource "google_cloud_run_v2_service" "default" {
    name         = var.cloudrun_name
    location     = var.region
    ingress      = var.ingress
    launch_stage = "BETA"  # Direct VPCを使用するため必要

    template {
        scaling {
            max_instance_count = 2
        }
        dynamic "volumes" {
            for_each = (var.sql_connection_name != null) ? [true] : []
            content {
                name = "cloudsql"  # CloudSQLを使用する場合は必ず"cloudsql"
                cloud_sql_instance {
                    instances = [var.sql_connection_name]
                }
            }
        }
        containers {
            image = var.image
            ports {
                container_port = 3000
            }
            volume_mounts {
                name = "cloudsql"
                mount_path = "/cloudsql"
            }
        }
        dynamic "vpc_access" {
            for_each = var.enable_vpc ? [true] : []
            content {
                network_interfaces {
                    network    = var.vpc_id
                    subnetwork = var.vpc_subnet_id
                }
                egress = "ALL_TRAFFIC"
            }
        }
        service_account = google_service_account.default.email
    }
}

resource "google_cloud_run_v2_service_iam_member" "default" {
    location = google_cloud_run_v2_service.default.location
    name     = google_cloud_run_v2_service.default.name
    role   = "roles/run.invoker"
    member = var.accessible_unauthorized ? "allUsers" : "serviceAccount:${google_service_account.default.email}"
}

resource "google_cloud_run_service_iam_member" "member" {
    for_each = var.accessible_cloudrun

    location = google_cloud_run_v2_service.default.location
    service  = each.value.cloudrun_id
    role     = each.value.role
    member   = "serviceAccount:${google_service_account.default.email}"
}

module "load_balancing_backend" {
    source               = "../../modules/LoadBalancingBackend"
    project_id           = var.project_id
    region               = var.region
    cloudrun_name        = google_cloud_run_v2_service.default.name
    oauth2_client_id     = var.oauth2_client_id
    oauth2_client_secret = var.oauth2_client_secret
    accessible_members   = var.accessible_members
}
