locals {
  name      = "${var.project}-${var.env}"
  az_suffix = [for az in var.azs : substr(az, length(az) - 2, 2)] # ["1a", "1b"]
}

# ---------- VPC (regional) e Internet Gateway (regional, en el borde de la VPC) ----------
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true # lo necesita el endpoint de RDS

  tags = { Name = "${local.name}-vpc" }
}

# El grupo de seguridad por defecto de la VPC queda sin reglas: nadie lo usa.
resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id

  tags = { Name = "${local.name}-sg-default-cerrado" }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = { Name = "${local.name}-igw" }
}

# ---------- Subredes (cada una vive en una zona) ----------
# Publicas: solo tienen el NAT Gateway de su zona. Ninguna tarea ni base de datos vive aqui.
resource "aws_subnet" "public" {
  count = length(var.azs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false # el NAT usa su propia IP elastica

  tags = { Name = "${local.name}-public-${local.az_suffix[count.index]}" }
}

# Privadas de la app: tareas Fargate y ALB interno, sin IP publica.
resource "aws_subnet" "app" {
  count = length(var.azs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.app_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = { Name = "${local.name}-app-${local.az_suffix[count.index]}" }
}

# Privadas de la BD: RDS principal y standby.
resource "aws_subnet" "db" {
  count = length(var.azs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.db_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = { Name = "${local.name}-db-${local.az_suffix[count.index]}" }
}

# ---------- NAT Gateway: uno por zona, para que la salida no dependa de una sola zona ----------
resource "aws_eip" "nat" {
  count = length(var.azs)

  domain = "vpc"

  tags = { Name = "${local.name}-eip-nat-${local.az_suffix[count.index]}" }
}

resource "aws_nat_gateway" "this" {
  count = length(var.azs)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = { Name = "${local.name}-nat-${local.az_suffix[count.index]}" }

  depends_on = [aws_internet_gateway.this]
}

# ---------- Rutas de las subredes publicas: salida directa por el Internet Gateway ----------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = { Name = "${local.name}-rt-public" }
}

resource "aws_route_table_association" "public" {
  count = length(var.azs)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ---------- Rutas de las tareas: salen por el NAT de su misma zona ----------
# Por aqui pasan ECR, CloudWatch Logs, SES y el cobro a Mercado Pago. Desde internet nadie puede entrar.
resource "aws_route_table" "app" {
  count = length(var.azs)

  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[count.index].id
  }

  tags = { Name = "${local.name}-rt-app-${local.az_suffix[count.index]}" }
}

resource "aws_route_table_association" "app" {
  count = length(var.azs)

  subnet_id      = aws_subnet.app[count.index].id
  route_table_id = aws_route_table.app[count.index].id
}

# ---------- Rutas de la BD: sin salida a internet ----------
resource "aws_route_table" "db" {
  vpc_id = aws_vpc.this.id

  tags = { Name = "${local.name}-rt-db" }
}

resource "aws_route_table_association" "db" {
  count = length(var.azs)

  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.db.id
}

# ---------- Grupos de seguridad: VPC Link -> ALB :8080 -> tareas :8080 -> RDS :5432 ----------
resource "aws_security_group" "vpclink" {
  name        = "${local.name}-sg-vpclink"
  description = "VPC Link de API Gateway"
  vpc_id      = aws_vpc.this.id
}

resource "aws_security_group" "alb" {
  name        = "${local.name}-sg-alb"
  description = "ALB interno de la API"
  vpc_id      = aws_vpc.this.id
}

resource "aws_security_group" "api" {
  name        = "${local.name}-sg-api"
  description = "Tareas Fargate de la API"
  vpc_id      = aws_vpc.this.id
}

resource "aws_security_group" "db" {
  name        = "${local.name}-sg-db"
  description = "RDS PostgreSQL"
  vpc_id      = aws_vpc.this.id
}

resource "aws_vpc_security_group_egress_rule" "vpclink_to_alb" {
  description                  = "VPC Link hacia el ALB interno en el puerto de la app"
  security_group_id            = aws_security_group.vpclink.id
  referenced_security_group_id = aws_security_group.alb.id
  ip_protocol                  = "tcp"
  from_port                    = var.app_port
  to_port                      = var.app_port
}

resource "aws_vpc_security_group_ingress_rule" "alb_from_vpclink" {
  description                  = "Solo el VPC Link entra al ALB"
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.vpclink.id
  ip_protocol                  = "tcp"
  from_port                    = var.app_port
  to_port                      = var.app_port
}

resource "aws_vpc_security_group_egress_rule" "alb_to_api" {
  description                  = "ALB hacia las tareas en el puerto de la app"
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.api.id
  ip_protocol                  = "tcp"
  from_port                    = var.app_port
  to_port                      = var.app_port
}

resource "aws_vpc_security_group_ingress_rule" "api_from_alb" {
  description                  = "Solo el ALB entra a la API"
  security_group_id            = aws_security_group.api.id
  referenced_security_group_id = aws_security_group.alb.id
  ip_protocol                  = "tcp"
  from_port                    = var.app_port
  to_port                      = var.app_port
}

# Las tareas salen por el NAT Gateway: ECR, CloudWatch Logs, SES y Mercado Pago.
# La entrada sigue cerrada: solo 8080 desde el ALB (regla api_from_alb).
resource "aws_vpc_security_group_egress_rule" "api_all" {
  description       = "Salida por el NAT Gateway: ECR, CloudWatch, SES y Mercado Pago"
  security_group_id = aws_security_group.api.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "db_from_api" {
  description                  = "Solo la API entra a PostgreSQL"
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.api.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}