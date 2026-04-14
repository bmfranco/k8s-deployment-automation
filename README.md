# 🚀 Kubernetes Deployment Automation

Este projeto demonstra a criação de uma infraestrutura automatizada na AWS utilizando Terraform, Kubernetes (Minikube), Helm e GitHub Actions com autenticação segura via OIDC.

---

##  Tecnologias Utilizadas

![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4?style=for-the-badge\&logo=terraform)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Orchestration-326CE5?style=for-the-badge\&logo=kubernetes)
![Helm](https://img.shields.io/badge/Helm-Package_Manager-0F1689?style=for-the-badge\&logo=helm)
![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?style=for-the-badge\&logo=amazonaws)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI/CD-2088FF?style=for-the-badge\&logo=githubactions)
![Docker](https://img.shields.io/badge/Docker-Container-2496ED?style=for-the-badge\&logo=docker)

---

##  Arquitetura

* EC2 provisionada via Terraform
* Cluster Kubernetes com Minikube
* Deploy da aplicação via Helm
* Pipeline CI/CD com GitHub Actions
* Backend remoto do Terraform em S3 (com versionamento)
* Autenticação segura via OIDC (sem uso de access keys)

---

##  Estrutura do Repositório

```
.
├── terraform/              # Infraestrutura como código (IAC)(AWS)
├── charts/nginx-app        # Helm Chart da aplicação
├── .github/workflows       # Pipeline CI/CD
├── docs/                   # Imagens do projeto
├── README.md
```

---

##  Provisionamento da Infraestrutura

### 1. Inicializar Terraform

```bash
cd terraform
terraform init
```

---

### 2. Aplicar infraestrutura

```bash
terraform apply
```

Isso irá criar:

* EC2 com Docker + Minikube + Kubectl + Helm
* Security Group
* Backend remoto em S3

---

## 🔐 Autenticação (OIDC)

O projeto utiliza autenticação via OIDC no GitHub Actions.

* O GitHub assume uma role IAM na AWS
* A trust policy restringe o acesso ao repositório

### Benefícios:

* Maior segurança
* Sem vazamento de credenciais
* Prática recomendada pela AWS

---

##  Pipeline CI/CD

O pipeline executa automaticamente a cada push na branch `main`.

### Etapas:

1. Validação do Helm Chart (`helm lint`)
2. Autenticação na AWS via OIDC
3. Conexão SSH com a EC2
4. Deploy com Helm:

```bash
helm upgrade --install nginx .
```

---

##  Aplicação

A aplicação consiste em um Nginx com conteúdo dinâmico.

A mensagem exibida é injetada via Helm:

```bash
--set message="Hello World da AsapTech - Deploy realizado via CI/CD (Commit: <SHA>)"
```

---

##  Validação

### 1. Verificar pods

```bash
kubectl get pods
```

---

### 2. Acessar aplicação

Como o serviço é do tipo ClusterIP, utilize port-forward:

```bash
kubectl port-forward svc/nginx 8080:80
```

Abra no navegador:

```
http://localhost:8080
```

---

##  Acesso remoto (via SSH)

```bash
ssh -i k8s-key.pem -L 8080:localhost:8080 ec2-user@<EC2_PUBLIC_IP>
```

Depois:

```
http://localhost:8080
```

---

##  Evidências

### ☁️ Bucket S3 (Terraform State)

![S3 Bucket](./docs/s3-bucket.png)

---

### 🚀 Deploy via CI/CD

![Deploy](./docs/deploy.png)

---

##  Conclusão

Este projeto demonstra a integração completa entre infraestrutura, orquestração e automação de deploy, seguindo boas práticas modernas de DevOps.
