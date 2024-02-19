resource "random_id" "default" {
    byte_length = 16
}

resource "google_compute_backend_bucket_signed_url_key" "default" {
    name           = "${var.cloudstorage_name}-key"
    key_value      = random_id.default.b64_url
    backend_bucket = google_compute_backend_bucket.default.name
}

# HTTPSのLoad Balancingの役割
resource "google_compute_backend_bucket" "default" {
    name        = "${var.cloudstorage_name}-backend"
    bucket_name = google_storage_bucket.default.name
}

resource "google_storage_bucket" "default" {
    name          = var.cloudstorage_name
    location      = var.location
    force_destroy = var.force_destroy

    public_access_prevention = var.public_access_prevention
}

resource "google_secret_manager_secret_version" "default" {
    secret      = var.secret_full_id
    secret_data =google_compute_backend_bucket_signed_url_key.default.key_value
}

