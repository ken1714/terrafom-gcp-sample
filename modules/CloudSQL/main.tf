resource "google_sql_database_instance" "default" {
    name             = var.sql_name
    region           = var.region
    database_version = var.database_version
    settings {
        tier = var.machine_type
        ip_configuration {
            ipv4_enabled                                  = false
            private_network                               = var.vpc_id
            enable_private_path_for_google_cloud_services = true
        }
    }

    deletion_protection  = var.deletion_protection
}

resource "google_sql_user" "user" {
    name     = var.user_name
    instance = google_sql_database_instance.default.name
    password = var.database_password
}

resource "google_secret_manager_secret_version" "default" {
    secret      = var.secret_full_id
    secret_data = var.database_password
}
