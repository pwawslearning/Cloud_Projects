# Blue-Green deployment with EC2 in AWS
![Image](https://github.com/user-attachments/assets/12654106-a4bb-43e4-aebf-8d86553d9506)

This project demonstrates a Blue-Green deployment strategy using Amazon EC2 instances behind an Application Load Balancer (ALB). The goal is to reduce downtime and risk by running two identical environments (Blue and Green) and switching traffic between them seamlessly.

## 💡 What is Blue-Green Deployment?

Blue-Green deployment is a version management strategy of application or webserver that reduces downtime and risk by running two identical environments:

- **Blue Environment**: Currently running production traffic.
- **Green Environment**: New version of the application deployed here for testing.

Once the new version is validated in the Green environment, the traffic is switched from Blue to Green by updating the listener with target group.

---

## 📦 Architecture Overview

- Two EC2 Auto Scaling Groups: one for Blue, one for Green.
- Launch Templates for version control of EC2 configs.
- An Application Load Balancer (ALB) routes traffic to the active environment.
- ALB Listener rules can be used to shift traffic.
- Health checks ensure only healthy targets receive traffic.

---
## 🚀 Deployment Steps

### 1. Launch Blue Environment

- Deploy EC2 instances (Auto Scaling Group) with the current stable app version.
- Register with the Load Balancer (Target Group: `blue-target-group`).
- Load balancer routes traffic to the Blue environment.

### 2. Launch Green Environment

- Deploy a new ASG with updated launch template or user data (new app version).
- Register instances in a separate target group (`green-target-group`).
- Test the Green environment independently (use a test listener or direct IP).

### 3. Switch Traffic

- After validation, update the ALB listener to forward traffic to the Green target group. (Command off the terraform config for blue traffic)
```
resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port = 80
  protocol = "HTTP"

  # Initially traffic forward to Blue environment
  # default_action {
  #   type = "forward"
  #   target_group_arn = aws_lb_target_group.blue-tg.arn
  # }

  # Shift the traffic to Green environment
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.green-tg.arn
  }
}

```
- Run terraform command to update the resources
```
  terraform plan
  terraform apply
```

- Optionally, deregister Blue environment from the load balancer.

### 4. Rollback (if needed)

- Simply switch the ALB back to the Blue target group if issues are found.

---

## 🧪 Testing

![Image](https://github.com/user-attachments/assets/ac1f6b2b-79bb-478e-8469-69efffb4e950)

---


## ✅ Benefits of Blue-Green Deployment

- Zero downtime deployments
- Easy rollback strategy
- Reduced risk during deployment
- Pre-production validation of new versions

---

## 🧹 Cleanup

To avoid charges:

- Terminate EC2 instances / ASGs not in use.
- Delete Load Balancer and Target Groups if no longer needed.

---
