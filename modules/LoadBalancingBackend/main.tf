# ネットワークエンドポイント
resource "google_compute_region_network_endpoint_group" "default" {
    name                  = "network-endpoint-${var.cloudrun_name}"
    network_endpoint_type = "SERVERLESS"
    region                = var.region
    cloud_run {
        # リクエストを送りたいCloud Run
        service = var.cloudrun_name
    }
}

# ネットワークエンドポイントを追跡するバックエンドサービス
resource "google_compute_backend_service" "default" {
    name        = "load-balancing-backend-${var.cloudrun_name}"
    protocol    = "HTTP"
    port_name   = "http"
    timeout_sec = 30

    backend {
        group = google_compute_region_network_endpoint_group.default.id
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
