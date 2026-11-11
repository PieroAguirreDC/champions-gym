variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "azs" {
  description = "Las 2 zonas: [sa-east-1a, sa-east-1b]."
  type        = list(string)
}

variable "vpc_cidr" {
  type = string
}

variable "app_subnet_cidrs" {
  type = list(string)
}

variable "db_subnet_cidrs" {
  type = list(string)
}

variable "app_port" {
  type = number
}
