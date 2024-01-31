# terraform apply毎に証明書の名前が一意に決定するようランダムな文字列を生成
resource "random_id" "default" {
    byte_length = 8
}

resource "google_certificate_manager_certificate" "default" {
    name        = "dns-cert-${random_id.default.hex}"
    description = "The default cert"
    scope       = "EDGE_CACHE"

    managed {
        domains = [
            google_certificate_manager_dns_authorization.default.domain
        ]
        dns_authorizations = [
            google_certificate_manager_dns_authorization.default.id
        ]
    }
}


resource "google_certificate_manager_dns_authorization" "default" {
    name        = "dns-auth-${random_id.default.hex}"
    description = "The default dnss"
    domain      = var.domain
}
