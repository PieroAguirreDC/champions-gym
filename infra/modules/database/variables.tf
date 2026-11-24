variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "db_subnet_ids" {
  type = list(string)
}

variable "sg_db_id" {
  type = string
}

variable "multi_az" {
  type = bool
}

variable "instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "engine_version" {
  description = "Version mayor; RDS elige la menor vigente."
  type        = string
  default     = "17"
}

variable "db_name" {
  type    = string
  default = "gym"
}

variable "db_username" {
  type    = string
  default = "gym_admin"
}