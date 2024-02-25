# オブジェクトストレージへのアクセス権
resource "google_storage_bucket_iam_member" "default" {
    bucket = var.cloudstorage_name
    role   = "roles/storage.objectAdmin"
    member = var.accessible_member
}

# オブジェクトストレージへの署名付きURL発行に必要な権限
# google_storage_bucket_iam_binding, google_cloud_run_service_iam_memberでは
# roles/iam.serviceAccountTokenCreatorをサポートしていない
resource "google_project_iam_binding" "default" {
    project = var.project_id
    role    = "roles/iam.serviceAccountTokenCreator"
    members = [var.accessible_member]
}

# オブジェクトストレージの署名付きURL発行用キーへのアクセス権
resource "google_secret_manager_secret_iam_member" "default" {
    secret_id = var.secret_id
    role      = "roles/secretmanager.secretAccessor"
    member    = var.accessible_member
}
