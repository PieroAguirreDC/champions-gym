# El estado vive en S3 (lo crea infra/bootstrap). Los datos del bucket estan en envs/prod.backend.hcl:
#   terraform init -backend-config=envs/prod.backend.hcl
terraform {
  backend "s3" {}
}
