profile = "dev-profile"
region  = "ap-southeast-1"
project = "waf-lab"

security_groups_config = {

  "alb" = {
    name        = "alb-sg"
    description = "Security group for Application Load Balancer"

    ingress_rules = {
      http = {
        description = "HTTP from internet"
        from_port   = 80
        to_port     = 80
        ip_protocol = "tcp"
        cidr_ipv4   = "0.0.0.0/0"
      }
    }

    egress_rules = {
      all = {
        description = "Allow all outbound"
        ip_protocol = "-1"
        cidr_ipv4   = "0.0.0.0/0"
      }
    }
  }

  "bh" = {
    name        = "bh-sg"
    description = "Security group for Bastion Host"

    ingress_rules = {
      ssh = {
        description = "SSH access from outside"
        from_port   = 22
        to_port     = 22
        ip_protocol = "tcp"
        cidr_ipv4   = "0.0.0.0/0"
      }
    }

    egress_rules = {
      all = {
        description = "Allow all outbound"
        ip_protocol = "-1"
        cidr_ipv4   = "0.0.0.0/0"
      }
    }
  }

  "app" = {
    name        = "app-sg"
    description = "Security group for application servers"

    ingress_rules = {
      http = {
        description    = "HTTP from ALB"
        from_port      = 5000
        to_port        = 5000
        ip_protocol    = "tcp"
        security_group = "alb"
      }

      ssh = {
        description    = "SSH access from bastion host"
        from_port      = 22
        to_port        = 22
        ip_protocol    = "tcp"
        security_group = "bh"
      }
    }

    egress_rules = {
      all = {
        description = "Allow all outbound"
        ip_protocol = "-1"
        cidr_ipv4   = "0.0.0.0/0"
      }
    }
  }
}

# Instances

instances = {
  bastion = {
    ami                 = "ami-0532913178263be11"
    instance_type       = "t3.micro"
    subnet              = "public"
    security_group      = "bh"
    associate_public_ip = true
  }

  app01 = {
    ami                 = "ami-08cf591fb76cd57da"
    instance_type       = "t3.micro"
    subnet              = "private"
    security_group      = "app"
    associate_public_ip = false
  }


  app02 = {
    ami                 = "ami-08cf591fb76cd57da"
    instance_type       = "t3.micro"
    subnet              = "private"
    security_group      = "app"
    associate_public_ip = false
  }
}

# loadbalancer
lb_config = {
  internal           = false
  load_balancer_type = "application"
}
lb_target_group_config = {
  app = {
    target_type = "instance"
    protocol    = "HTTP"
    port        = 5000

    health_check = {
      enabled           = true
      healthy_threshold = 3
      interval          = 30
      timeout           = 5
      protocol          = "HTTP"
      path              = "/"
    }
  }
}

lb_listeners = {
  http = {
    port     = 80
    protocol = "HTTP"

    default_action = {
      type             = "forward"
      target_group_key = "app"
    }
  }
}

# WAF

waf_block_ip_addresses = [
  "195.133.129.0/32"
]

waf_enable_geo_block = false

waf_geo_block_countries = []