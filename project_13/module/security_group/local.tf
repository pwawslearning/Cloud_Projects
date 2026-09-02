locals {

  ingress_flat = {
    for rule in flatten([
      for sg_key, sg in var.security_groups_config : [
        for rule_key, rule in sg.ingress_rules : {
          key = "${sg_key}.${rule_key}"

          sg_key      = sg_key
          rule_key    = rule_key
          description = rule.description
          from_port   = rule.from_port
          to_port     = rule.to_port
          ip_protocol = rule.ip_protocol

          cidr_ipv4 = try(rule.cidr_ipv4, null)
          cidr_ipv6 = try(rule.cidr_ipv6, null)

          security_group = try(rule.security_group, null)

          prefix_list_id = try(rule.prefix_list_id, null)
        }
      ]
    ]) : rule.key => rule
  }


  egress_flat = {
    for rule in flatten([
      for sg_key, sg in var.security_groups_config : [
        for rule_key, rule in sg.egress_rules : {
          key = "${sg_key}.${rule_key}"

          sg_key      = sg_key
          rule_key    = rule_key
          description = rule.description

          from_port = try(rule.from_port, null)
          to_port   = try(rule.to_port, null)

          ip_protocol = rule.ip_protocol

          cidr_ipv4 = try(rule.cidr_ipv4, null)
          cidr_ipv6 = try(rule.cidr_ipv6, null)

          security_group = try(rule.security_group, null)

          prefix_list_id = try(rule.prefix_list_id, null)
        }
      ]
    ]) : rule.key => rule
  }
}