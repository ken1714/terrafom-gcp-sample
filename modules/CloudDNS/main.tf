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

# ドメインマッピングで発生する各種DNSレコード情報を動的に収集
# locals {
#     dns_records_A     = [for rr in google_cloud_run_domain_mapping.default.status[0].resource_records : rr.rrdata if rr.type == "A"]
#     dns_records_AAAA  = [for rr in google_cloud_run_domain_mapping.default.status[0].resource_records : rr.rrdata if rr.type == "AAAA"]
#     dns_records_CNAME = [for rr in google_cloud_run_domain_mapping.default.status[0].resource_records : rr.rrdata if rr.type == "CNAME"]
# }

# # A、AAAAレコードがない場合はCNAMEレコードを生成
# resource "google_dns_record_set" "CNAME" {
#     count        = length(local.dns_records_A) > 0 || length(local.dns_records_AAAA) > 0 ? 0 : 1
#     name         = "${var.domain}."
#     type         = "CNAME"
#     ttl          = 3600
#     managed_zone = google_dns_managed_zone.default.name
#     rrdatas      = local.dns_records_CNAME
# }

# # Aレコードがある場合はAレコードを生成
# resource "google_dns_record_set" "A" {
#     count        = length(local.dns_records_A) > 0 ? 1 : 0
#     managed_zone = google_dns_managed_zone.default.name
#     name         = "${var.domain}."
#     type         = "A"
#     ttl          = 3600
#     rrdatas      = local.dns_records_A
# }

# # AAAAレコードがある場合はAAAAレコードを生成
# resource "google_dns_record_set" "AAAA" {
#     count        = length(local.dns_records_AAAA) > 0 ? 1 : 0
#     managed_zone = google_dns_managed_zone.default.name
#     name         = "${var.domain}."
#     type         = "AAAA"
#     ttl          = 3600
#     rrdatas      = local.dns_records_AAAA
# }
