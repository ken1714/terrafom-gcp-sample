variable project_id {
    type    = string
}

variable region {
    type    = string
    default = "asia-northeast1"
}

variable backend_image {
    type    = string
}

variable frontend_image {
    type    = string
}


variable database_password {
    type      = string
    sensitive = true
}

variable domain {
    type = string
}

variable dns_records_A {
    type = list(string)
}

variable dns_records_AAAA {
    type = list(string)
}
