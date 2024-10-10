# Deploy securely HAproxy with SSL enable for multiple docker containers by using Terraform

![haproxy](https://github.com/user-attachments/assets/6e5e33bc-feb2-4bba-9936-1bf67c760533)

This repository contains Terraform code to deploy and configure HAProxy with SSL termination to load balance traffic across multiple Docker containers. HAProxy will handle SSL termination and distribute traffic to backend services running in Docker containers.

## 📋 Table of Contents
1. [Prerequisites](#prerequisites)
2. [Features](#features)
3. [Tech Stack](#tech-stack)
4. [Getting Started](#getting-started)
5. [Usage](#usage)
6. [Contributing](#contributing)

---

### Prerequisites
Ensure the following tools are installed on your machine:
- [ ] Docker installed
- [ ] Docker hub account
- [ ] OpenSSL (for generating SSL certificates if needed)
- [ ] Terraform installed
- [ ] Git

---

## ✨ Features <a name="features"></a>
- Automated deployment of multiple Docker containers.
- HAProxy configured for SSL termination using self-signed or provided certificates.
- Load balancing for high availability and traffic distribution.
- Infrastructure provisioning and management via Terraform.
- Easily customizable to suit different environments and use cases.

---

## 🚀 Tech Stack <a name="tech-stack"></a>
- **Backend**: [nginx]
- **Frontend**: [HAproxy]
- **Security**: [openssl]
- **tools**: [ipvsadm]
- **DevOps**: Docker, Terraform

---

## 🛠 Getting Started <a name="getting-started"></a>


### Installation
1. **Clone the repository**:
    ```bash
    git clone https://github.com/pwawslearning/Cloud_Projects.git
    cd project_3
    ```

2. **Install dependencies**:
    ```bash
    # generate key and certificates for HAproxy
    $ cd haproxy
    $ openssl req -new -x509 -days 365 -nodes -newkey rsa:2048 -keyout haproxy.key -out haproxy.crt -subj "/CN=localhost1"
    $ cat haproxy.crt | openssl x509 --noout --text 
    $ cd ..
    $ bash -c 'cat haproxy.crt haproxy.key >> haproxy.pem'
    ```

3. **Initialize Terraform Providers**:
    ```bash
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
7. **Set virtual IP infront of HAproxy**:
    ```bash
    # check the usable ports on machine
    $ sudo netstat -tuln
    $ sudo ipvsadm -A -t 10.10.10.10:443 -s rr
    $ sudo ipvsadm -A -t 10.10.10.10:8000 -s rr
   ```
8. **Port Mapping**:
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
    
9. **Access the web server**:
  - Open your browser and navigate to `https://10.10.10.10:443`.
  - Access `http://10.10.10.10:8000` for traffic monitoring.
    
10. **Cleanup**
  - To remove the infrastructure created by Terraform, run:
    ```bash
    terraform destroy
    ```
---
