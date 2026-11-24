#RDS PostgreSQL Multi-AZ
variable "db_multi_az" {
  description = "true = con standby en la otra zona (diagrama). false = sin standby, mas barato mientras desarrollan."
  type        = bool
  default     = true
}

module "database" {
  source = "./modules/database"

  project       = var.project
  env           = var.env
  db_subnet_ids = module.network.db_subnet_ids
  sg_db_id      = module.network.sg_db_id
  multi_az      = var.db_multi_az
}

output "db_address" {
  value = module.database.db_address
}