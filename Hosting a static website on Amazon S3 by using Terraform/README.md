# Hosting a static website on Amazon S3 by using terraform
![s3 drawio](https://github.com/user-attachments/assets/1048ab8d-9cca-459f-9f62-9c86a3769ff1)

## Goal

Goal of this project is to deploy a sample website on Amazon S3 by using a feature which static website hosting in AWS cloud and apply Bucket policy to allow access to the bucket from public.

## Pre-Requisites

1. AWS IAM user access key & secret key accessing S3.
2. Install Terraform IaC in your machine

## Deployment the resources by using Terraform code

1. Create S3 bucket in your desired region.
2. If you want backup, enable versioning.
3. Update Bucket ACL to public access.
4. Upload the objects to bucket.
5. Create IAM policy to allow Bucket objects from the public.



