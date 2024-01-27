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
        vpc_access {
            network_interfaces {
                network    = var.vpc_id
                subnetwork = var.vpc_subnet_id
            }
            egress = "ALL_TRAFFIC"
        }
    }
}

resource "google_cloud_run_v2_service_iam_member" "noauth" {
    # TODO: 全ユーザに外部公開しているため修正する
    location = google_cloud_run_v2_service.default.location
    name     = google_cloud_run_v2_service.default.name
    role   = "roles/run.invoker"
    member = "allUsers"
}
