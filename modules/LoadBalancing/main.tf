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

# ネットワークエンドポイントを追跡するバックエンドサービス
resource "google_compute_backend_service" "default" {
    name        = "frontend"
    protocol    = "HTTP"
    port_name   = "http"
    timeout_sec = 30

    backend {
        group = google_compute_region_network_endpoint_group.frontend.id
    }

    # IAP設定を紐づける
    iap {
        oauth2_client_id     = var.oauth2_client_id
        oauth2_client_secret = var.oauth2_client_secret
    }
}

# IAPによりアクセス可能なGoogleアカウントを制限
# 組織に属していない場合、terrform applyの前に手動でOAuthの同意画面を構成する必要がある
resource "google_iap_web_backend_service_iam_binding" "default" {
    project             = var.project_id
    web_backend_service = google_compute_backend_service.default.name
    role                = "roles/iap.httpsResourceAccessor"
    members             = var.accessible_members
}


# フロントエンドへのネットワークエンドポイント
resource "google_compute_region_network_endpoint_group" "frontend" {
    name                  = "frontend-endpoint"
    network_endpoint_type = "SERVERLESS"
    region                = var.region
    cloud_run {
        # リクエストを送りたいCloud Run
        service = var.frontend_cloudrun_name
    }
}

# ロードバランサーの設定
# URLマッピングを行い、ロードバランサーバックエンドへ振り分ける
resource "google_compute_url_map" "default" {
    name = "${var.project_id}-urlmap"

    default_service = google_compute_backend_service.default.id

    host_rule {
        hosts        = [var.domain]
        path_matcher = "app"
    }

    path_matcher {
        name            = "app"
        default_service = google_compute_backend_service.default.id
        path_rule {
            paths   = ["/*"]
            service = google_compute_backend_service.default.id
        }
    }
}

# HTTPSプロキシ
resource "google_compute_target_https_proxy" "default" {
    name             = "${var.project_id}-https-proxy"
    url_map          = google_compute_url_map.default.id
    ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
    ssl_policy       = google_compute_ssl_policy.default.id
}

# Trafficルール
resource "google_compute_global_forwarding_rule" "default" {
    name        = "${var.project_id}-load-balancer"
    target      = google_compute_target_https_proxy.default.id
    ip_address  = google_compute_global_address.default.address
    ip_protocol = "TCP"
    port_range  = "443"
}
