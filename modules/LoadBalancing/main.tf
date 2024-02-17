resource "google_compute_global_address" "default" {
    name = "${var.project_id}-address"
}

# Googleが発行および更新するSSL証明書
resource "google_compute_managed_ssl_certificate" "default" {
    name = "load-balancer-cert"
    managed {
        domains = ["${var.domain}"]
    }
}

# SSLポリシー
resource "google_compute_ssl_policy" "default" {
    name            = "${var.project_id}-ssl-policy"
    profile         = "MODERN"
    min_tls_version = "TLS_1_2"
}

# ロードバランサーの設定
# URLマッピングを行い、ロードバランサーバックエンドへ振り分ける
resource "google_compute_url_map" "default" {
    name = "${var.project_id}-urlmap"

    default_service = var.default_backend_id

    host_rule {
        hosts        = [var.domain]
        path_matcher = "app"
    }

    path_matcher {
        name            = "app"
        default_service = var.default_backend_id

        dynamic "path_rule" {
            for_each = var.path_rules
            content {
                paths = [path_rule.value.path]
                service = path_rule.value.service
            }
        }
    }
}

# HTTPSプロキシ
resource "google_compute_target_https_proxy" "default" {
    name             = "${var.project_id}-https-proxy"
    url_map          = google_compute_url_map.default.id
    ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
    ssl_policy       = google_compute_ssl_policy.default.id
    certificate_map  = "//certificatemanager.googleapis.com/${var.certificate_map_id}"
}

# Trafficルール
resource "google_compute_global_forwarding_rule" "default" {
    name        = "${var.project_id}-load-balancer"
    target      = google_compute_target_https_proxy.default.id
    ip_address  = google_compute_global_address.default.address
    ip_protocol = "TCP"
    port_range  = "443"
}

# HTTP向け
resource "google_compute_url_map" "https_redirect" {
    name = "${var.project_id}-urlmap-https-redirect"
    default_url_redirect {
        redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
        https_redirect         = true
        strip_query            = false
    }
}

# HTTPプロキシ
resource "google_compute_target_http_proxy" "https_redirect" {
    name             = "${var.project_id}-http-proxy"
    url_map          = google_compute_url_map.https_redirect.id
}

resource "google_compute_global_forwarding_rule" "https_redirect" {
    name   = "${var.project_id}-load-balancer-http"

    target = google_compute_target_http_proxy.https_redirect.id
    port_range = "80"
    ip_address = google_compute_global_address.default.address
}
