#API Gateway HTTP API + VPC Link + ALB interno.
module "api_gateway" {
  source = "./modules/api_gateway"

  project        = var.project
  env            = var.env
  vpc_id         = module.network.vpc_id
  app_subnet_ids = module.network.app_subnet_ids
  sg_vpclink_id  = module.network.sg_vpclink_id
  sg_alb_id      = module.network.sg_alb_id
  app_port       = local.app_port
}

output "api_endpoint" {
  description = "URL directa de API Gateway"
  value       = module.api_gateway.api_endpoint
}