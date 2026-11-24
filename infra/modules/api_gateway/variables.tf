variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "app_subnet_ids" {
  type = list(string)
}

variable "sg_vpclink_id" {
  type = string
}

variable "sg_alb_id" {
  type = string
}

variable "app_port" {
  type = number
}