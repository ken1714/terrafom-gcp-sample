# Cloud DNSのゾーン設定
resource "google_dns_managed_zone" "default" {
    name       = "${var.project_id}-dns-zone"
    dns_name   = "${var.domain}."
    visibility = "public"
    dnssec_config {
        state = "on"
    }
    cloud_logging_config {
        enable_logging = true
    }
}

# Cloud DNSとCloud Runのドメインマッピング
resource "google_cloud_run_domain_mapping" "default" {
    location = var.region
    name     = var.domain

    metadata {
        namespace = var.project_id
    }

    spec {
        route_name = var.frontend_cloudrun_name
    }
}

# DNSレコードの登録(取得したドメイン名でアクセスできるようにする)
# TODO: rrdatasを動的に変更できるようにする
# Aレコードを生成
resource "google_dns_record_set" "A" {
    managed_zone = google_dns_managed_zone.default.name
    name         = "${var.domain}."
    type         = "A"
    ttl          = 3600
    rrdatas      = var.dns_records_A
}

# AAAAレコードを生成
resource "google_dns_record_set" "AAAA" {
    managed_zone = google_dns_managed_zone.default.name
    name         = "${var.domain}."
    type         = "AAAA"
    ttl          = 3600
    rrdatas      = var.dns_records_AAAA
}

# CNAMEレコードを生成(Google CloudでDNSを管理している場合は必要)
resource "google_dns_record_set" "CNAME" {
    managed_zone = google_dns_managed_zone.default.name
    name         = var.dns_auth_record_name_CNAME
    type         = "CNAME"
    ttl          = 300
    rrdatas      = [var.dns_auth_record_data_CNAME]
}
