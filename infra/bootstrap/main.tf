# Se aplica UNA sola vez desde la PC de Fabrizio (dueno de la cuenta), con estado local:
#   cd infra/bootstrap && terraform init && terraform apply
# Crea lo que debe existir antes que todo lo demas. NO se destruye con el workflow "apagar".

terraform {
  required_version = "1.14.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.67.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = var.project
      ManagedBy = "terraform"
      Purpose   = "bootstrap"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "sa-east-1"
}

variable "project" {
  type    = string
  default = "champions-gym"
}

data "aws_caller_identity" "actual" {}

locals {
  account_id = data.aws_caller_identity.actual.account_id
}

output "account_id" {
  description = "Va en infra/envs/prod.backend.hcl"
  value       = local.account_id
}

