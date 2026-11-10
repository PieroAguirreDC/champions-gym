data "aws_caller_identity" "actual" {}

locals {
  azs        = ["${var.aws_region}a", "${var.aws_region}b"] # las 2 zonas del diagrama
  app_port   = 8080
  account_id = data.aws_caller_identity.actual.account_id
}
