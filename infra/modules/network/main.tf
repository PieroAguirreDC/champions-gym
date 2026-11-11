locals {
  name      = "${var.project}-${var.env}"
  az_suffix = [for az in var.azs : substr(az, length(az) - 2, 2)] # ["1a", "1b"]
}

# ---------- VPC (regional) e Internet Gateway (regional, en el borde de la VPC) ----------
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true # lo necesitan Cloud Map y el endpoint de RDS

  tags = { Name = "${local.name}-vpc" }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = { Name = "${local.name}-igw" }
}

# ---------- Subredes (cada una vive en una zona) ----------
resource "aws_subnet" "app" {
  count = length(var.azs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.app_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = { Name = "${local.name}-app-${local.az_suffix[count.index]}" }
}

resource "aws_subnet" "db" {
  count = length(var.azs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.db_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = { Name = "${local.name}-db-${local.az_suffix[count.index]}" }
}

# ---------- Rutas de las tareas: salida directa por el Internet Gateway (sin NAT) ----------
resource "aws_route_table" "app" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = { Name = "${local.name}-rt-app" }
}

resource "aws_route_table_association" "app" {
  count = length(var.azs)

  subnet_id      = aws_subnet.app[count.index].id
  route_table_id = aws_route_table.app.id
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

# ---------- Grupos de seguridad: VPC Link -> tareas :8080 -> RDS :5432 ----------
resource "aws_security_group" "vpclink" {
  name        = "${local.name}-sg-vpclink"
  description = "VPC Link de API Gateway"
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

resource "aws_vpc_security_group_egress_rule" "vpclink_to_api" {
  security_group_id            = aws_security_group.vpclink.id
  referenced_security_group_id = aws_security_group.api.id
  ip_protocol                  = "tcp"
  from_port                    = var.app_port
  to_port                      = var.app_port
}

resource "aws_vpc_security_group_ingress_rule" "api_from_vpclink" {
  security_group_id            = aws_security_group.api.id
  referenced_security_group_id = aws_security_group.vpclink.id
  ip_protocol                  = "tcp"
  from_port                    = var.app_port
  to_port                      = var.app_port
}

# Las tareas salen por el Internet Gateway: ECR, CloudWatch Logs, SES y Mercado Pago.
# La entrada sigue cerrada: solo 8080 desde el VPC Link (regla api_from_vpclink).
resource "aws_vpc_security_group_egress_rule" "api_all" {
  security_group_id = aws_security_group.api.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "db_from_api" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.api.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}
