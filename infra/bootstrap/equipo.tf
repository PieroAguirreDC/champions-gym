# RNF 1: solo el administrador (Fabrizio) cambia la infraestructura.
# Piero y Joaquin entran a la consola con usuarios de SOLO LECTURA: si intentan cambiar algo,
# AWS lo rechaza (AccessDenied) y queda registrado en CloudTrail.
variable "team_members" {
  description = "Integrantes con acceso de solo lectura."
  type        = list(string)
  default     = ["piero", "joaquin"]
}

resource "aws_iam_group" "solo_lectura" {
  name = "${var.project}-solo-lectura"
}

resource "aws_iam_group_policy_attachment" "solo_lectura" {
  for_each = toset([
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    "arn:aws:iam::aws:policy/IAMUserChangePassword",
  ])

  group      = aws_iam_group.solo_lectura.name
  policy_arn = each.value
}

# Leer no incluye los secretos: ni los parametros de SSM ni el estado de Terraform.
resource "aws_iam_group_policy" "sin_secretos" {
  name  = "sin-secretos"
  group = aws_iam_group.solo_lectura.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "NoLeerParametros"
        Effect   = "Deny"
        Action   = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParametersByPath", "ssm:GetParameterHistory"]
        Resource = "arn:aws:ssm:*:${local.account_id}:parameter/${var.project}/*"
      },
      {
        Sid      = "NoLeerElEstado"
        Effect   = "Deny"
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.tfstate.arn}/*"
      },
    ]
  })
}

resource "aws_iam_user" "equipo" {
  for_each = toset(var.team_members)

  name          = "${var.project}-${each.key}"
  force_destroy = true
}

resource "aws_iam_user_group_membership" "equipo" {
  for_each = aws_iam_user.equipo

  user   = each.value.name
  groups = [aws_iam_group.solo_lectura.name]
}

resource "aws_iam_user_login_profile" "equipo" {
  for_each = aws_iam_user.equipo

  user                    = each.value.name
  password_reset_required = true
}

output "consola_url" {
  value = "https://${local.account_id}.signin.aws.amazon.com/console"
}

output "passwords_iniciales" {
  description = "terraform output -json passwords_iniciales (cada uno la cambia al entrar)"
  value       = { for k, v in aws_iam_user_login_profile.equipo : k => v.password }
  sensitive   = true
}
