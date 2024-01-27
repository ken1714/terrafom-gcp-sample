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

variable database_password {
    type      = string
    sensitive = true
}
