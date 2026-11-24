output "api_endpoint" {
  description = "https://xxxx.execute-api.sa-east-1.amazonaws.com (CloudFront lo usa como origen)."
  value       = aws_apigatewayv2_api.this.api_endpoint
}

output "api_id" {
  value = aws_apigatewayv2_api.this.id
}

#ECS solo puede usar el target group cuando ya esta conectado al ALB.
output "target_group_arn" {
  description = "El servicio ECS registra aqui sus tareas."
  value       = aws_lb_target_group.api.arn
  depends_on  = [aws_lb_listener.http]
}