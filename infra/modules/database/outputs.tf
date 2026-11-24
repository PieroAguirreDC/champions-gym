output "db_address" {
  value = aws_db_instance.this.address
}

output "db_port" {
  value = aws_db_instance.this.port
}

output "db_name" {
  value = aws_db_instance.this.db_name
}

output "db_username" {
  value = aws_db_instance.this.username
}

output "db_password_ssm_arn" {
  value = aws_ssm_parameter.db_password.arn
}

output "db_instance_id" {
  value = aws_db_instance.this.identifier
}