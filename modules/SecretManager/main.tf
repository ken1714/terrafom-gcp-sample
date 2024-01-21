resource "google_secret_manager_secret" "default" {
    secret_id = var.secret_id
    replication {
        auto {}
    }
}
