# ---------------------------------------------------------
# Application Load Balancer
# ---------------------------------------------------------

resource "aws_lb" "alb" {
  name = "${var.project}-${var.environment}-alb"

  security_groups = var.lb_security_group
  subnets         = var.lb_subnets

  internal           = var.lb_config.internal
  load_balancer_type = var.lb_config.load_balancer_type

  tags = {
    Name = "${var.project}-${var.environment}-alb"
  }
}


# ---------------------------------------------------------
# Target Groups
# ---------------------------------------------------------

resource "aws_lb_target_group" "lb_tg" {
  for_each = var.lb_target_group_config

  name        = "${var.project}-${var.environment}-${each.key}-tg"
  vpc_id      = var.vpc_id
  target_type = each.value.target_type
  protocol    = each.value.protocol
  port        = each.value.port

  health_check {
    enabled           = each.value.health_check.enabled
    healthy_threshold = each.value.health_check.healthy_threshold
    interval          = each.value.health_check.interval
    timeout           = each.value.health_check.timeout
    protocol          = each.value.health_check.protocol
    path              = each.value.health_check.path
  }

  tags = {
    Name = "${var.project}-${var.environment}-${each.key}-tg"
  }
}


# ---------------------------------------------------------
# ALB Listener
# ---------------------------------------------------------

resource "aws_lb_listener" "this" {
  depends_on = [aws_lb.alb]
  for_each   = var.lb_listeners

  load_balancer_arn = aws_lb.alb.arn

  port     = each.value.port
  protocol = each.value.protocol

  default_action {
    type = each.value.default_action.type

    target_group_arn = (
      each.value.default_action.type == "forward"
      ? aws_lb_target_group.lb_tg[
        each.value.default_action.target_group_key
      ].arn
      : null
    )

    dynamic "redirect" {
      for_each = (
        each.value.default_action.type == "redirect"
        && each.value.default_action.redirect != null
        ? [each.value.default_action.redirect]
        : []
      )

      content {
        port        = redirect.value.port
        protocol    = redirect.value.protocol
        status_code = redirect.value.status_code
      }
    }

    dynamic "fixed_response" {
      for_each = (
        each.value.default_action.type == "fixed-response"
        && each.value.default_action.fixed_response != null
        ? [each.value.default_action.fixed_response]
        : []
      )

      content {
        content_type = fixed_response.value.content_type
        message_body = fixed_response.value.message_body
        status_code  = fixed_response.value.status_code
      }
    }

  }

  tags = {
    Name = "${var.project}-${var.environment}-${each.key}-listener"
  }
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = {
    for attachment in flatten([
      for target_group_key, instance_names in var.target_group_instances : [
        for instance_name in instance_names : {
          key              = "${target_group_key}-${instance_name}"
          target_group_key = target_group_key
          instance_name    = instance_name
        }
      ]
    ]) : attachment.key => attachment
  }

  target_group_arn = aws_lb_target_group.lb_tg[
    each.value.target_group_key
  ].arn

  target_id = var.instance_ids[
    each.value.instance_name
  ]
}