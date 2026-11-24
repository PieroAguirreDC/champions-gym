locals {
  name = "${var.project}-${var.env}"
}

resource "aws_lb" "api" {
  name                       = "${local.name}-alb"
  internal                   = true 
  load_balancer_type         = "application"
  subnets                    = var.app_subnet_ids
  security_groups            = [var.sg_alb_id]
  drop_invalid_header_fields = true
}

resource "aws_lb_target_group" "api" {
  name                 = "${local.name}-api"
  port                 = var.app_port
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.vpc_id
  deregistration_delay = 30

  health_check {
    path                = "/api/actuator/health/liveness"
    matcher             = "200"
    interval            = 15
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.api.arn
  port              = var.app_port 
  protocol          = "HTTP" 

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

resource "aws_apigatewayv2_vpc_link" "this" {
  name               = "${local.name}-vpclink"
  subnet_ids         = var.app_subnet_ids
  security_group_ids = [var.sg_vpclink_id]
}

resource "aws_apigatewayv2_api" "this" {
  name          = "${local.name}-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "ecs" {
  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "ANY"
  integration_uri        = aws_lb_listener.http.arn
  connection_type        = "VPC_LINK"
  connection_id          = aws_apigatewayv2_vpc_link.this.id
  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_route" "api" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /api/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.ecs.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true
}