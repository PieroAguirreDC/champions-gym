# Variables de entorno y secretos extra que recibe el contenedor de la API (los usa ecs.tf).
# Cada integrante edita SOLO su bloque; asi dos pull requests en paralelo no chocan.
# Secretos: NOMBRE = ARN de un parametro SecureString de SSM (nunca el valor).

# ---------- Fabrizio ----------
locals {
  app_env_fabrizio     = {}
  app_secrets_fabrizio = {}
}

# ---------- Piero ----------
locals {
  app_env_piero     = {}
  app_secrets_piero = {}
}

# ---------- Joaquin ----------
locals {
  app_env_joaquin     = {}
  app_secrets_joaquin = {}
}

resource "aws_db_subnet_group" "cg_db_subnets" {
  name       = "champions-gym-db-subnets"
  subnet_ids = var.private_subnet_ids
  
  tags = {
    Name = "champions-gym-db-subnet-group"
  }
}

resource "aws_db_instance" "cg_rds" {
  identifier             = "champions-gym-db"
  engine                 = "postgres"
  engine_version         = "15.4" 
  instance_class         = "db.t3.micro" 
  allocated_storage      = 20
  storage_type           = "gp3"
  db_name                = "championsgym"
  username               = var.db_username
  password               = var.db_password
  
  db_subnet_group_name   = aws_db_subnet_group.cg_db_subnets.name
  vpc_security_group_ids = [] 
  
  multi_az               = true
  publicly_accessible    = false
  skip_final_snapshot    = true 
}

resource "aws_service_discovery_private_dns_namespace" "cg_namespace" {
  name        = "championsgym.local"
  description = "Namespace privado para los microservicios"
  vpc         = var.vpc_id
}

resource "aws_service_discovery_service" "reservas_service" {
  name = "reservas" # DNS interno para el microservicio de Piero
  
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.cg_namespace.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  
  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_security_group" "vpc_link_sg" {
  name        = "vpc-link-sg"
  description = "Security Group para el VPC Link del API Gateway"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_apigatewayv2_vpc_link" "cg_vpc_link" {
  name               = "champions-gym-vpc-link"
  security_group_ids = [aws_security_group.vpc_link_sg.id]
  subnet_ids         = var.private_subnet_ids
}

resource "aws_apigatewayv2_api" "cg_http_api" {
  name          = "champions-gym-api"
  protocol_type = "HTTP"
  description   = "Puerta de enlace principal para Champion's Gym"
}