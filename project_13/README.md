# ALB integrate with WAF and create WAF rules

This demo purposes to test for block unwanted URL requests to deployed webapp through ALB by using WAF

## Table of Contents

- [Architecture without WAF]
- [Deploy infrastructure by terraform]
- [Test without WAF]
- [Architecture with WAF]
- [Apply WAF]
- [Test after WAF applied]
- [Teardown the resources]

## Architecture
![architecture]

## Deploy infrastructure by terraform

Update `terraform.tfvars` file

Run terraform
```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

## Test without WAF

### Normal traffic

http://ALB-DNS

!image.png

### Path /admin

http://ALB-DNS/admin

!image.png

### String match

http://ALB-DNS/?test=blocked-string

!image.png

### Custom User-Agent rule

curl -i -H "User-Agent: lab-security-test" http://ALB-DNS/

```bash
~/PW$ curl -i -H "User-Agent: lab-security-test" http://waf-lab-lb-1095108916.ap-southeast-1.elb.amazonaws.com
HTTP/1.1 200 OK
Date: Thu, 13 Aug 2026 03:22:34 GMT
Content-Type: text/html; charset=utf-8
Content-Length: 1335
Connection: keep-alive
Server: gunicorn
```

### Size constraint

curl -i -X POST --data "$(python3 -c 'print("A"*10000)')" http://ALB-DNS/large-payload

```bash
~/PW$ curl -i -X POST --data "$(python3 -c 'print("A"*10000)')" http://waf-lab-lb-1095108916.ap-southeast-1.elb.amazonaws.com/large-payload
HTTP/1.1 200 OK
Date: Thu, 13 Aug 2026 03:25:45 GMT
Content-Type: text/html; charset=utf-8
Content-Length: 1059
Connection: keep-alive
Server: gunicorn
```

## Architecture with WAF
![architecture with waf]

## Apply WAF

run terraform for specific resource

```bash
terraform init --upgrade
terraform apply --target=module.WAF
```

## Test after WAF applied

### Normal traffic

http://ALB-DNS

!image.png

### Path /admin

http://ALB-DNS/admin

!image.png

### String match

http://ALB-DNS/?test=blocked-string

!image.png

### Custom User-Agent rule

curl -i -H "User-Agent: lab-security-test" http://ALB-DNS/

```bash
~/PW$ curl -i -H "User-Agent: lab-security-test" http://waf-lab-lb-1095108916.ap-southeast-1.elb.amazonaws.com
HTTP/1.1 403 Forbidden
Server: awselb/2.0
Date: Thu, 13 Aug 2026 06:11:06 GMT
Content-Type: text/html
Content-Length: 118
Connection: keep-alive

<html>
<head><title>403 Forbidden</title></head>
<body>
<center><h1>403 Forbidden</h1></center>
</body>
</html>
```

### Size constraint

curl -i -X POST --data "$(python3 -c 'print("A"*10000)')" http://ALB-DNS/large-payload

```bash
~/PW$ curl -i -X POST --data "$(python3 -c 'print("A"*10000)')" http://waf-lab-lb-1095108916.ap-southeast-1.elb.amazonaws.com/large-payload
HTTP/1.1 403 Forbidden
Server: awselb/2.0
Date: Thu, 13 Aug 2026 06:16:03 GMT
Content-Type: text/html
Content-Length: 118
Connection: keep-alive

<html>
<head><title>403 Forbidden</title></head>
<body>
<center><h1>403 Forbidden</h1></center>
</body>
</html>
```

## Teardown the resources

Destroy the resouces after testing
```bash
terraform destroy
```
