variable project_id {
    type = string
}

variable region {
    type = string
}

variable domain {
    type = string
}

variable certificate_map_id {
    type = string
}

variable default_backend_id {
    type = string
}

variable path_rules {
    type = map(object({
        path    = string
        service = string
    }))
}
