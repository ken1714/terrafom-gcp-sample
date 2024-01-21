variable sql_name {
    type = string
}

variable region {
    type = string
}

variable database_version {
    type = string
}

variable machine_type {
    type = string
}

variable vpc_id {
    type = string
}

variable deletion_protection {
    type = string
}

variable user_name {
    type = string
}

variable database_password {
    type      = string
    sensitive = true
}

variable secret_full_id {
    type = string
}
