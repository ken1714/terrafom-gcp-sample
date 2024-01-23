locals {
    services = toset([
        "compute.googleapis.com",
        "secretmanager.googleapis.com",
        "servicenetworking.googleapis.com",
        "sql-component.googleapis.com",
        "sqladmin.googleapis.com",
        "iam.googleapis.com",
        "iap.googleapis.com",
        "run.googleapis.com",
    ])
}

provider "google" {
    project     = var.project_id
    region      = var.region
}

resource "google_project_service" "service" {
    for_each = local.services
    project  = var.project_id
    service  = each.value
}

module "backend" {
    source              = "../../modules/CloudRun"
    cloudrun_name       = "backend"
    region              = var.region
    ingress             = "INGRESS_TRAFFIC_ALL"
    sql_connection_name = module.postgresql.connection_name
    image               = "us-docker.pkg.dev/cloudrun/container/hello"
    vpc_id              = module.vpc.network_id
    vpc_subnet_id       = module.vpc.subnet_id
}

module "postgresql" {
    source              = "../../modules/CloudSQL"
    sql_name            = "postgresql"
    region              = var.region
    database_version    = "POSTGRES_15"
    machine_type        = "db-f1-micro"
    vpc_id              = module.vpc.network_id
    user_name           = "sample-user"
    database_password   = var.database_password
    deletion_protection = true
    secret_full_id       = module.secret_manager.secret_full_id
}

module "vpc" {
    source        = "../../modules/VPC"
    project_id    = var.project_id
    region        = var.region
    vpc_name      = "vpc"
    ip_cidr_range = "192.168.0.0/16"
}

module "secret_manager" {
    depends_on = [google_project_service.service]
    source    = "../../modules/SecretManager"
    secret_id = "secret"
}
