locals {
    services = toset([
        "dns.googleapis.com",
        "certificatemanager.googleapis.com",
        "compute.googleapis.com",
        "secretmanager.googleapis.com",
        "servicenetworking.googleapis.com",
        "sql-component.googleapis.com",
        "sqladmin.googleapis.com",
        "vpcaccess.googleapis.com",
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
    # terraform applyの際、depends_onのモジュールやリソースを生成し終えた後に本モジュールのリソースを作成したい
    depends_on = [google_project_service.service]
    source              = "../../modules/CloudRun"
    cloudrun_name       = "backend"
    region              = var.region
    ingress             = "INGRESS_TRAFFIC_INTERNAL_ONLY"
    sql_connection_name = module.postgresql.connection_name
    image               = var.backend_image
    vpc_id              = module.vpc.network_id
    vpc_subnet_id       = module.vpc.subnet_id
}

module "frontend" {
    depends_on = [google_project_service.service]
    source              = "../../modules/CloudRun"
    cloudrun_name       = "frontend"
    region              = var.region
    ingress             = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
    sql_connection_name = null  # SQLには接続しない
    image               = var.frontend_image
    vpc_id              = module.vpc.network_id
    vpc_subnet_id       = module.vpc.subnet_id
}

module "postgresql" {
    depends_on = [google_project_service.service]
    source              = "../../modules/CloudSQL"
    sql_name            = "postgresql"
    region              = var.region
    database_version    = "POSTGRES_15"
    machine_type        = "db-f1-micro"
    vpc_id              = module.vpc.network_id
    user_name           = "SampleUser"
    database_password   = var.database_password
    deletion_protection = true
    secret_full_id       = module.secret_manager.secret_full_id
}

module "certificate_manager" {
    depends_on             = [google_project_service.service]
    source                 = "../../modules/CertificateManager"
    domain                 = var.domain
}

module "load_balancing" {
    depends_on             = [google_project_service.service]
    source                 = "../../modules/LoadBalancing"
    project_id             = var.project_id
    region                 = var.region
    domain                 = var.domain
    frontend_cloudrun_name = module.frontend.cloudrun_name
    frontend_cloudrun_id   = module.frontend.cloudrun_id
}


module "dns" {
    depends_on                 = [google_project_service.service]
    source                     = "../../modules/CloudDNS"
    project_id                 = var.project_id
    region                     = var.region
    domain                     = var.domain
    frontend_cloudrun_name     = module.frontend.cloudrun_id
    dns_records_A              = var.dns_records_A
    dns_records_AAAA           = var.dns_records_AAAA
    dns_auth_record_name_CNAME = module.certificate_manager.dns_auth_record_name_CNAME
    dns_auth_record_data_CNAME = module.certificate_manager.dns_auth_record_data_CNAME
}

module "vpc" {
    depends_on = [google_project_service.service]
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
