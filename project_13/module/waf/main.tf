############################################
# WAF IP Set
############################################

resource "aws_wafv2_ip_set" "block_ip_blocklist" {
  name               = "${var.project}-${var.environment}-block-ip-blocklist"
  description        = "IP addresses blocked for WAF security blocking"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"

  addresses = var.block_ip_addresses

  tags = {
    Name        = "${var.project}-${var.environment}-block-ip-blocklist"
    Project     = var.project
    Environment = var.environment
  }
}


############################################
# AWS WAF Web ACL
############################################

resource "aws_wafv2_web_acl" "this" {
  name        = "${var.project}-${var.environment}-waf"
  description = "AWS WAF Web ACL for Application Load Balancer"

  scope = "REGIONAL"

  ##########################################
  # Default action
  ##########################################

  default_action {
    allow {}
  }


  ##########################################
  # Rule 0 - Block block IP
  ##########################################

  rule {
    name     = "block-block-ip"
    priority = 0

    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.block_ip_blocklist.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "block-block-ip"
      sampled_requests_enabled   = true
    }
  }


  ##########################################
  # Rule 1 - Block String
  ##########################################

  rule {
    name     = "block-string"
    priority = 1

    action {
      block {}
    }

    statement {
      byte_match_statement {
        search_string         = "blocked-string"
        positional_constraint = "CONTAINS"

        field_to_match {
          query_string {}
        }

        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "block-string"
      sampled_requests_enabled   = true
    }
  }


  ##########################################
  # Rule 2 - Block Bad User-Agent
  ##########################################

  rule {
    name     = "block-bad-useragent"
    priority = 2

    action {
      block {}
    }

    statement {
      byte_match_statement {
        search_string         = "lab-security-block"
        positional_constraint = "CONTAINS"

        field_to_match {
          single_header {
            name = "user-agent"
          }
        }

        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "block-bad-useragent"
      sampled_requests_enabled   = true
    }
  }


  ##########################################
  # Rule 3 - Restrict /admin
  ##########################################

  rule {
    name     = "restrict-admin"
    priority = 3

    action {
      block {}
    }

    statement {
      byte_match_statement {
        search_string         = "/admin"
        positional_constraint = "STARTS_WITH"

        field_to_match {
          uri_path {}
        }

        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "restrict-admin"
      sampled_requests_enabled   = true
    }
  }


  ##########################################
  # Rule 4 - Size Constraint
  ##########################################

  rule {
    name     = "size-constraint"
    priority = 4

    action {
      block {}
    }

    statement {
      size_constraint_statement {
        comparison_operator = "GT"
        size                = 8192

        field_to_match {
          body {
            oversize_handling = "MATCH"
          }
        }

        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "size-constraint"
      sampled_requests_enabled   = true
    }
  }


  ##########################################
  # Rule 5 - Geo Block
  ##########################################

  dynamic "rule" {
    for_each = var.enable_geo_block ? [1] : []

    content {
      name     = "geo-block"
      priority = 5

      action {
        block {}
      }

      statement {
        geo_match_statement {
          country_codes = var.geo_block_countries
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "geo-block"
        sampled_requests_enabled   = true
      }
    }
  }


  ##########################################
  # Rule 6 - AWS Managed Common Rule Set
  ##########################################

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 6

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }


  ##########################################
  # Web ACL visibility
  ##########################################

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project}-${var.environment}-waf"
    sampled_requests_enabled   = true
  }

  tags = {
    Name        = "${var.project}-${var.environment}-waf"
    Project     = var.project
    Environment = var.environment
  }
}


############################################
# Associate WAF with ALB
############################################

resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}