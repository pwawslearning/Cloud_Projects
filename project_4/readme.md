## Deploy Tier2 web application on AWS cloud

![Screenshot from 2024-10-27 01-28-53](https://github.com/user-attachments/assets/549c216e-4f28-4152-a948-3ecb4a5f8a13)

## Objective

This project aims to create a robust highly available web application infrastructure using a Tier 2 architecture on AWS cloud. This architecture comprises a web tier that handle user requests and database tier for data storage. I used Terraform for Infrastructure as Code to deploy and manage AWS resources efficiently.

## 📋 Table of Contents
1. [Prerequisites](#prerequisites)
2. [Project Structure](#project-structure)
3. [Tech Stack](#tech-stack)
4. [Getting Started](#getting-started)
5. [Reference](#reference)

---

## Prerequisites

Before getting started, ensure you have the following:

1. **AWS account**: For deployment the network,compute,database, storage and security resources on AWS cloud.
2. **Install awscli and secret_key & access_key**: securely connect to AWS resources.
3. **Terraform**: Installed terraform

---

## ✨ Project Structure <a name="project-structure"></a>
```plaintext

├── Terraform
│   ├── infra.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── terraform.tfvars
│   ├── user_data.sh
│   └── variables.tf
└── web_app code
    ├── fetch.php
    ├── index.php
    ├── insert.php
    ├── merlin.jpg
    └── mysql
```
---

## 🚀 Tech Stack <a name="tech-stack"></a>

- **Backend**: php, MySQL(database)
- **Frontend**: Apache webserver
- **Security**: Key_pair, Security group for all layers
- **tools**: aws cli, terraform
- **DevOps**: Terraform, php, html

---

## 🛠 Getting Started <a name="getting-started"></a>


### Implementation
1. **Clone the repository**:
    ```bash
    git clone https://github.com/pwawslearning/Cloud_Projects.git
    cd project_4
    ```

2. **Upload the codes for webserver to s3 bucket**
   ```
   aws s3 cp index.php s3://t2-webapp-bucket01 --profile pw-programmatic
   aws s3 cp insert.php s3://t2-webapp-bucket01 --profile pw-programmatic
   aws s3 cp fetch.php s3://t2-webapp-bucket01 --profile pw-programmatic
   aws s3 cp merlin.jpg s3://t2-webapp-bucket01 --profile pw-programmatic
   
   ```

3. **Initialize Terraform Providers**:
    ```bash
    cd Terraform
    terraform init
    ```
4. **Check Terraform syntax**:
    ```bash
    terraform fmt
    terraform validate
    ```
5. **Check expected results**:
    ```bash
    terraform plan
    ```
6. **Provisioning infrastructure**:
    ```bash
    terraform apply
    ```
7. **Verify the deployment resources**:
    ```bash
    # check the usable ports on machine
    $ sudo netstat -tuln
    $ sudo ipvsadm -A -t 10.10.10.10:443 -s rr
    $ sudo ipvsadm -A -t 10.10.10.10:8000 -s rr
   ```
9. **Port Mapping**:
    ```bash
    # for backend access
    $ sudo ipvsadm -a -t 10.10.10.10:443 -r 172.18.0.5:443 -m
    $ sudo ipvsadm -a -t 10.10.10.10:443 -r 172.18.0.6:443 -m

    # for desk board access to check haproxy status
    $ sudo ipvsadm -a -t 10.10.10.10:8000 -r 172.18.0.6:8404 -m
    $ sudo ipvsadm -a -t 10.10.10.10:8000 -r 172.18.0.5:8404 -m
    $ sudo ipvsadm -l
    IP Virtual Server version 1.2.1 (size=4096)
    Prot LocalAddress:Port Scheduler Flags
      -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
    TCP  10.10.10.10:https rr
      -> 172.18.0.5:https             Masq    1      0          0         
      -> 172.18.0.6:https             Masq    1      0          0         
    TCP  10.10.10.10:8000 rr
      -> 172.18.0.5:8404              Masq    1      0          0         
      -> 172.18.0.6:8404              Masq    1      0          0 
    ```
    
10. **Access the web server**:
  - Open your browser and navigate to `https://10.10.10.10:443`.
  - Access `http://10.10.10.10:8000` for traffic monitoring.
    
10. **Cleanup**
  - To remove the infrastructure created by Terraform, run:
    ```bash
    terraform destroy
    ```

