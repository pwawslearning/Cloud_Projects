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
   - *VPC*
   ![Screenshot from 2024-11-03 23-13-39](https://github.com/user-attachments/assets/f2c683a1-4f6a-4c1f-894b-d399b9e82916)

   - *EC2 created by Autoscaling Group*
   ![Screenshot from 2024-11-03 23-14-39](https://github.com/user-attachments/assets/ae15a5a1-50b3-4002-95d2-26c547406a8a)

   - *Loadbalancer*
   ![Screenshot from 2024-11-03 23-15-04](https://github.com/user-attachments/assets/23300cc1-fba0-49f2-ae06-bc0dbaf9ea44)

   - *Databases*
   ![Screenshot from 2024-11-03 23-15-27](https://github.com/user-attachments/assets/14f3fd7f-4ba6-48a7-9445-3a7f3ad1b304)

   - *Outputs upon completed terraform*
     
   ![Screenshot from 2024-11-03 23-16-26](https://github.com/user-attachments/assets/b310926d-cd26-47b5-92c7-c6b1c8aff935)

   - *Website page after deployment*
   ![Screenshot from 2024-11-03 23-17-03](https://github.com/user-attachments/assets/fd520f97-1824-43c5-b02a-d05c482ede65)


8. **Add database information into insert.php**:
   - insert.php will be using master-db for write processes.
     ![2024-11-03_23-56](https://github.com/user-attachments/assets/f579dc68-f647-4f73-afdf-44ad91aff7cd)
   - fetch.php will be using replica-db for enquiry the data.
     ![2024-11-04_00-00](https://github.com/user-attachments/assets/b2965afc-275c-4d35-ad5e-1fb39463776a)
   - Create table ***users*** in master-db
     ```
        CREATE TABLE users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(50) NOT NULL,
        email VARCHAR(50) NOT NULL
        );
     ```
10. **Verification**:
  - Fill the data and check the database.
    ![2024-11-04_00-16](https://github.com/user-attachments/assets/4a723c95-6316-4555-9ed2-81e7ee859117)
    ![2024-11-04_00-16_1](https://github.com/user-attachments/assets/a5cf524d-2c2b-4511-9305-01c3514ad34d)

  - Enquiry the data in database
    ![2024-11-04_00-23](https://github.com/user-attachments/assets/3aa84720-b96f-436a-b9bf-8d4d19cd6994)

    
10. **Cleanup**
  - To remove the created aws resources by using terraform, run:
    ```bash
    terraform destroy
    ```

