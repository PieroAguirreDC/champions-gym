locals {
  name = "${var.project}-${var.env}"
}

#La contrasena la genera Terraform y se guarda en parameter store.
resource "random_password" "db" {
  length  = 24
  special = false
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/${var.project}/${var.env}/db/password"
  type  = "SecureString"
  value = random_password.db.result
}

resource "aws_db_subnet_group" "this" {
  name       = "${local.name}-db"
  subnet_ids = var.db_subnet_ids
}

resource "aws_db_instance" "this" {
  identifier     = "${local.name}-db"
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db.result

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.sg_db_id]
  publicly_accessible    = false

  multi_az = var.multi_az

  #Respaldo diario
  backup_retention_period = 7
  backup_window           = "08:00-08:45"
  #Mantenimiento de AWS 
  maintenance_window = "sun:09:00-sun:10:00"
  #Parches menores de PostgreSQL
  auto_minor_version_upgrade = true

  copy_tags_to_snapshot = true

  skip_final_snapshot = true
  deletion_protection = false
  apply_immediately   = true
}