# ---------------------------------------------------------
# Security Groups
# ---------------------------------------------------------

resource "aws_security_group" "sg" {
  for_each = var.security_groups_config

  name        = each.value.name
  description = each.value.description
  vpc_id      = var.vpc_id

  tags = merge(
    each.value.tags,
    {
      Name = each.value.name
    }
  )
}


# ---------------------------------------------------------
# Ingress Rules
# ---------------------------------------------------------

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = local.ingress_flat

  security_group_id = aws_security_group.sg[each.value.sg_key].id

  description = each.value.description
  from_port   = each.value.from_port
  to_port     = each.value.to_port
  ip_protocol = each.value.ip_protocol

  cidr_ipv4 = each.value.cidr_ipv4
  cidr_ipv6 = each.value.cidr_ipv6

  referenced_security_group_id = (
    each.value.security_group != null
    ? aws_security_group.sg[each.value.security_group].id
    : null
  )

  prefix_list_id = each.value.prefix_list_id
}


# ---------------------------------------------------------
# Egress Rules
# ---------------------------------------------------------

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = local.egress_flat

  security_group_id = aws_security_group.sg[each.value.sg_key].id

  description = each.value.description
  from_port   = each.value.from_port
  to_port     = each.value.to_port
  ip_protocol = each.value.ip_protocol

  cidr_ipv4 = each.value.cidr_ipv4
  cidr_ipv6 = each.value.cidr_ipv6

  referenced_security_group_id = (
    each.value.security_group != null
    ? aws_security_group.sg[each.value.security_group].id
    : null
  )

  prefix_list_id = each.value.prefix_list_id
}