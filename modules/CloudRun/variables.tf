variable cloudrun_name {
    type = string
}

variable region {
    type = string
}

variable ingress {
    type = string
}

variable sql_connection_name {
    type    = string
    default = null
}

variable image {
    type = string
}

variable vpc_id {
    type = string
}

variable vpc_subnet_id {
    type = string
}
