# Fabrizio: VPC, subredes, Internet Gateway y grupos de seguridad.
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "app_subnet_cidrs" {
  description = "Subredes publicas de las tareas Fargate (1a y 1b)."
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "db_subnet_cidrs" {
  description = "Subredes privadas de RDS (1a y 1b)."
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

module "network" {
  source = "./modules/network"

  project          = var.project
  env              = var.env
  azs              = local.azs
  vpc_cidr         = var.vpc_cidr
  app_subnet_cidrs = var.app_subnet_cidrs
  db_subnet_cidrs  = var.db_subnet_cidrs
  app_port         = local.app_port
}

output "vpc_id" {
  value = module.network.vpc_id
}
