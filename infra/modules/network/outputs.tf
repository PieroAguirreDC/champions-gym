output "vpc_id" {
  value = aws_vpc.this.id
}

# depends_on: quien use estas subredes espera a que existan las rutas al Internet Gateway
# (si no, las primeras tareas no pueden descargar la imagen de ECR).
output "app_subnet_ids" {
  value      = aws_subnet.app[*].id
  depends_on = [aws_route_table_association.app]
}

output "db_subnet_ids" {
  value = aws_subnet.db[*].id
}

output "sg_vpclink_id" {
  value = aws_security_group.vpclink.id
}

output "sg_api_id" {
  value = aws_security_group.api.id
}

output "sg_db_id" {
  value = aws_security_group.db.id
}
