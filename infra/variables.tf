# Variables comunes. Las de cada modulo estan en su propio archivo (network.tf, database.tf...).

variable "project" {
  description = "Nombre del proyecto: prefijo de todos los recursos."
  type        = string
  default     = "champions-gym"
}

variable "env" {
  description = "Entorno en AWS. QA es local con docker-compose."
  type        = string

  validation {
    condition     = contains(["prod"], var.env)
    error_message = "En AWS solo existe el entorno prod."
  }
}

variable "aws_region" {
  description = "Region del diseno (Sao Paulo)."
  type        = string
  default     = "sa-east-1"
}

variable "image_tag" {
  description = "Tag de la imagen en ECR = SHA del commit. Lo pasa el pipeline (o el Integrante en el primer despliegue)."
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC principal"
  type        = string
}

variable "private_subnet_ids" {
  description = "Lista de IDs de las subredes privadas"
  type        = list(string)
}

variable "db_username" {
  description = "Administrador de la BD de Champion's Gym"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Contraseña de la BD"
  type        = string
  sensitive   = true
}