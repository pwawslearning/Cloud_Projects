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

1. **GitLab Account**: To clone the codes.
2. **AWS account**: For deployment the network,compute,database, storage and security resources on AWS cloud.
3. **Install awscli and secret_key & access_key**: securly connect to AWS resources.
4. **Terraform**: Installed terraform

---

## ✨ Project Structure <a name="project-structure"></a>
```plaintext
.
├── dockerfile
├── .git
├── .gitlab-ci.yml
├── k8s
│   ├── deployment.yaml
│   ├── secret.yaml
│   └── service.yaml
├── nginx
│   └── index.html
├── nginx.conf
└── README.md
```
---

## 🚀 Tech Stack <a name="tech-stack"></a>

- **Backend**: nginx
- **Frontend**: Kubernetes api-resources(service, deployment and pods)
- **Security**: Kubernetes secret
- **tools**: Gitlab runner, kubectl
- **DevOps**: Docker, Gitlab CICD, Kubernetes

---

## 🛠 Getting Started <a name="getting-started"></a>


### Implementation
1. **Dockerfile**:
    ```dockerfile
    # Use the official Nginx image as the base image
      FROM nginx:latest

      # Copy custom configuration file from the current     directory to the container
      COPY nginx.conf /etc/nginx/nginx.conf

      # Copy static website files from the current directory to the container
      COPY nginx /usr/share/nginx/html

      # Expose port
      EXPOSE 80

      # Run Nginx in the foreground
      CMD ["nginx", "-g", "daemon off;"]

    ```
    **HTMLfile**
      ```html
      <html>
      <body>
      <h1>Hello World</h1>
      <p>Welcome to my project</p>
      </body>
      </html>

      ```
      Push codes to my project repository
2. **Running pipeline**:
    
- build .gitlab-ci.yaml file by using pipeline editor
    ```yaml
    stages:
    - build

  variables:
      DOCKER_IMAGE: $CI_REGISTRY_IMAGE
    
  build:
    image: docker
    stage: build
    services:
      - docker:dind
    script: 
      - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
      - docker build -t $DOCKER_IMAGE:latest .
      - docker push $DOCKER_IMAGE:latest
    ```
- run gitlab runner:

    Setting>>CICD>>Runner and create new project runner
    ```bash
      $ sudo gitlab-runner register
      Runtime platform                                    arch=amd64 os=linux pid=43104 revision=44feccdf version=17.0.0
      Running in system-mode.                            
                                                        
      Enter the GitLab instance URL (for example, https://gitlab.com/):
      https://gitlab.com
      Enter the registration token:
      <your created token>
      Verifying runner... is valid                        runner=jbsSxRXcY
      Enter a name for the runner. This is stored only in the local config.toml file:
      Enter an executor: ssh, docker, docker+machine, instance, custom, shell, parallels, virtualbox, docker-windows, kubernetes, docker-autoscaler:
      docker
      Enter the default Docker image (for example, ruby:2.7):
      alpine:latest
      Runner registered successfully
    ```

3. **Installation agent for kubernetes cluster**:
  - create agent repository
  - build config.yaml
    ```bash
    .gitlab/agents/<agent-name>/config.yaml
    ```
  - integrate with kubernetes cluster adding below yaml code in config.yaml
    ```yaml
    ci_access:
      projects:
        - id: path/to/project
    ```
4. **create secret in kubernetes to integrate gitlab repository**:
    ```bash
    kubectl create secret docker-registry <secret_name> --docker-server=registry.gitlab.com --docker-username='username' --docker-password='password' --dry-run=client -o yaml > secret.yaml
   ```
5. **Create manifest for deployment and service**:

    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      namespace: cicd
      name: my-service
    spec:
      type: NodePort # modify service type
      selector:
        app: app
      ports:
        - protocol: TCP
          port: 8080
          targetPort: 80
    
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      namespace: cicd
      name: app-python
      labels:
        app: app
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: app
      template:
        metadata:
          labels:
            app: app
        spec:
          imagePullSecrets:
          - name: my-secret # created secret
          containers:
          - name: app
            image: registry.gitlab.com/cicd3812942/nginx-project:latest # from gitlab container registry
            ports:
            - containerPort: 80
    ```
6. **Create deployment stage**:
    ```yaml
    stages:
      - build
      - deploy

    variables:
        DOCKER_IMAGE: $CI_REGISTRY_IMAGE
        KUBE_CONTEXT: cicd3812942/k8s-cluster-connection:k8s-connection
      
    build:
      image: docker
      stage: build
      services:
        - docker:dind
      script: 
        - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
        - docker build -t $DOCKER_IMAGE:latest .
        - docker push $DOCKER_IMAGE:latest

    deploy:
      stage: deploy
      image:
        name: bitnami/kubectl:latest
        entrypoint: ['']
      script:
        - kubectl config get-contexts
        - kubectl config use-context $KUBE_CONTEXT
        - kubectl get nodes -o wide
        - kubectl create ns cicd || echo "Namespace already exists"
        - kubectl apply -f k8s/deployment.yaml
        - kubectl apply -f k8s/service.yaml
        - kubectl get all -n cicd
        - echo "Successfully deploy nginx webserver"

    ```
7. **Run the jobs for both build and deploy stages**:
  - Verify kubernetes api resources (service, deployment and pods)
    ```bash
    kubectl get nodes -o wide
    NAME                STATUS   ROLES                  AGE   VERSION    INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION       CONTAINER-RUNTIME
    123-control-plane   Ready    control-plane,master   44d   v1.23.17   172.18.0.2    <none>        Debian GNU/Linux 11 (bullseye)   5.15.0-102-generic   containerd://1.7.1
    123-worker          Ready    <none>                 44d   v1.23.17   172.18.0.4    <none>        Debian GNU/Linux 11 (bullseye)   5.15.0-102-generic   containerd://1.7.1
    123-worker2         Ready    <none>                 44d   v1.23.17   172.18.0.3    <none>        Debian GNU/Linux 11 (bullseye)   5.15.0-102-generic   containerd://1.7.1
    ```
    ```bash
    $ kubectl get all -n cicd
      NAME                              READY   STATUS    RESTARTS   AGE
      pod/app-python-684df7d8f8-dsnsf   1/1     Running   0          63m

      NAME                 TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)          AGE
      service/my-service   NodePort   10.123.21.2   <none>        8080:31421/TCP   31h

      NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
      deployment.apps/app-python   1/1     1            1           63m

      NAME                                    DESIRED   CURRENT   READY   AGE
      replicaset.apps/app-python-684df7d8f8   1         1         1       63m
    ```
9. **Access the web server**:
  - Open your browser and browse to `http://<node_ip>:<node_port`.
    
10. **Cleanup**
  - To delete devployment and service in kubernetes, run:
    ```bash
    kubectl delete -f development.yaml
    ```
