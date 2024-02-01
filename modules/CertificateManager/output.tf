output dns_auth_record_name_CNAME {
    value = google_certificate_manager_dns_authorization.default.dns_resource_record[0].name
}

output dns_auth_record_data_CNAME {
    value = google_certificate_manager_dns_authorization.default.dns_resource_record[0].data
}
