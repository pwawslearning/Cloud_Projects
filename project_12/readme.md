# VPC Flow Logs with CloudWatch in AWS

![Image](https://github.com/user-attachments/assets/be865a90-4b21-4a81-8a11-9486b2e40f5c)

This lab sets up **VPC Flow Logs** to capture information about the IP traffic going to and from network interfaces in your VPC, and sends those logs to **Amazon CloudWatch Logs** for storage, analysis, and alerting.

---

## 📘 What Are VPC Flow Logs?

VPC Flow Logs allow you to capture information about the IP traffic going to and from ENIs (Elastic Network Interfaces) in your VPC. This is useful for:

- Monitoring traffic for security analysis
- Troubleshooting connectivity issues
- Capturing rejected traffic
- Auditing network access

---

## 📦 Architecture Overview

- **VPC Flow Logs** are created at the VPC, Subnet, or Network Interface level.
- Logs are sent to **CloudWatch Logs Group**.
- **IAM Role** is used to grant VPC Flow Logs permission to write to CloudWatch.
- Logs can be filtered, searched, and used for metric creation or alarms.

---

## 🚀 Deployment Steps

- Create a VPC, subnet, igw and route table for infrastructure set up.
- Launch a “Hello world” simple html webpage on EC2
- Configuring Log Delivery Destinations **CloudWatch**
- IAM role for publishing flow logs to CloudWatch Logs with **VPC Flow Logs** service on trust relationship.
- Create **VPC Flow Logs** with destination **CloudWatch log group** and **IAM role**

---
## 🧪 Querying logs in CloudWatch
![Image](https://github.com/user-attachments/assets/c385e792-1da2-4f0d-ac87-94adf6bb31db)

## 🧹 Cleanup
To avoid charges:
```
terraform destroy --auto-approve
```
---