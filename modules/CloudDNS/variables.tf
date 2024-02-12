variable project_id {
    type = string
}

variable region {
    type = string
}

variable domain {
    type = string
}

variable frontend_cloudrun_name {
    type = string
}

variable dns_records_A {
    type = list(string)
}

variable dns_auth_record_name_CNAME {
    type = string
}

variable dns_auth_record_data_CNAME {
    type = string
}
