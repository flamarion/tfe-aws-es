# Load Balancer
resource "aws_lb" "lb" {
  name               = "${var.owner}-tfe-es-lb"
  load_balancer_type = "application"
  security_groups    = [module.lb_sg.sg_id]
  subnets            = data.terraform_remote_state.vpc.outputs.public_subnets_id
  tags = {
    Name = "${var.owner}-tfe-es-lb"
  }
}

# LB Target groups
resource "aws_lb_target_group" "tg_https" {
  name                 = "${var.owner}-tg-tfe-es-${var.https_port}"
  port                 = var.https_port
  protocol             = var.https_proto
  vpc_id               = data.terraform_remote_state.vpc.outputs.vpc_id
  deregistration_delay = 30
  health_check {
    path                = "/_health_check"
    protocol            = var.https_proto
    port                = var.https_port
    matcher             = "200"
    interval            = 60
    timeout             = 30
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 604800
    enabled         = true
  }

  tags = {
    Name = "${var.owner}-tfe-es-tg-https"
  }
}

# resource "aws_lb_target_group" "tg_replicated" {
#   name                 = "${var.owner}-tg-tfe-es-${var.replicated_port}"
#   port                 = var.replicated_port
#   protocol             = var.https_proto
#   vpc_id               = data.terraform_remote_state.vpc.outputs.vpc_id
#   deregistration_delay = 30
#   health_check {
#     path                = "/dashboard"
#     protocol            = var.https_proto
#     port                = var.replicated_port
#     matcher             = "200,301,302"
#     interval            = 60
#     timeout             = 30
#     healthy_threshold   = 2
#     unhealthy_threshold = 10
#   }
#   tags = {
#     Name = "${var.owner}-tfe-es-tg-replicated"
#   }
# }



# HashiCorp wildcard certificate
data "aws_acm_certificate" "hashicorp_success" {
  domain      = "*.hashicorp-success.com"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

# LB Listeners
resource "aws_lb_listener" "listener_https" {
  load_balancer_arn = aws_lb.lb.arn
  port              = var.https_port
  protocol          = var.https_proto
  certificate_arn   = data.aws_acm_certificate.hashicorp_success.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_https.arn
  }
}

# LB Listener Rules
resource "aws_lb_listener_rule" "asg_https" {
  listener_arn = aws_lb_listener.listener_https.arn
  priority     = 97

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_https.arn
  }
}

