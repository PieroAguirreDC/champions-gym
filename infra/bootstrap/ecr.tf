# Repositorio de imagenes de la API. Cada imagen se etiqueta con el SHA del commit.
resource "aws_ecr_repository" "api" {
  name                 = "${var.project}-api"
  image_tag_mutability = "IMMUTABLE" # una etiqueta = un commit; no se puede pisar
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true # busca vulnerabilidades al subir
  }
}

resource "aws_ecr_lifecycle_policy" "api" {
  repository = aws_ecr_repository.api.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Guardar solo las 15 imagenes mas recientes (alcanza para el rollback)"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 15
      }
      action = { type = "expire" }
    }]
  })
}

output "ecr_repository_url" {
  value = aws_ecr_repository.api.repository_url
}
