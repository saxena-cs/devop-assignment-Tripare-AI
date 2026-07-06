locals {
  db_engine         = "postgres"
  db_engine_version = "16.3"
  db_port           = 5432
  db_name           = "hotelapp"
}

module "network" {
  source = "../../modules/network"

  project_name             = var.project_name
  vpc_cidr                 = var.vpc_cidr
  public_subnet_cidrs      = ["10.20.1.0/24", "10.20.2.0/24"]
  private_app_subnet_cidrs = ["10.20.11.0/24", "10.20.12.0/24"]
  private_db_subnet_cidrs  = ["10.20.21.0/24", "10.20.22.0/24"]
  db_port                  = local.db_port
}

module "rds" {
  source = "../../modules/rds"

  project_name              = var.project_name
  private_db_subnet_ids     = module.network.private_db_subnet_ids
  rds_sg_id                 = module.network.rds_sg_id
  db_engine                 = local.db_engine
  db_engine_version         = local.db_engine_version
  db_instance_class         = "db.t3.small"
  allocated_storage         = 50
  db_name                   = local.db_name
  db_username               = var.db_username
  db_password               = var.db_password
  backup_retention_period   = 7
  deletion_protection       = true
  multi_az                  = true
}

module "ecs" {
  source = "../../modules/ecs"

  project_name           = var.project_name
  aws_region             = var.aws_region
  vpc_id                 = module.network.vpc_id
  public_subnet_ids      = module.network.public_subnet_ids
  private_app_subnet_ids = module.network.private_app_subnet_ids
  alb_sg_id              = module.network.alb_sg_id
  ecs_sg_id              = module.network.ecs_sg_id

  container_image = "nginx:latest"
  container_port  = 80
  desired_count   = 2
  task_cpu        = 512
  task_memory     = 1024

  db_host = module.rds.db_endpoint
  db_port = module.rds.db_port
  db_name = module.rds.db_name
}
