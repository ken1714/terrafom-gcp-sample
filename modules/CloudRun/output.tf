output cloudrun_name {
    value = google_cloud_run_v2_service.default.name
}

output cloudrun_id {
    value = google_cloud_run_v2_service.default.id
}
