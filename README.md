# Kubernetes Deployment Automation

Este projeto demonstra a criação de uma infraestrutura 100% automatizada e reproduzível na AWS utilizando Terraform, Kubernetes (Minikube), Helm e GitHub Actions com autenticação segura via OIDC.

---

## Tecnologias Utilizadas

![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4?style=for-the-badge\&logo=terraform)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Orchestration-326CE5?style=for-the-badge\&logo=kubernetes)
![Helm](https://img.shields.io/badge/Helm-Package_Manager-0F1689?style=for-the-badge\&logo=helm)
![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?style=for-the-badge\&logo=amazonaws)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI/CD-2088FF?style=for-the-badge\&logo=githubactions)
![Docker](https://img.shields.io/badge/Docker-Container-2496ED?style=for-the-badge\&logo=docker)

---

## Arquitetura

* EC2 provisionada via Terraform
* Cluster Kubernetes com Minikube (iniciado automaticamente via systemd)
* Deploy da aplicação via Helm
* Pipeline CI/CD com GitHub Actions
* Backend remoto do Terraform em S3 com versionamento
* Autenticação via OIDC (sem uso de access keys)

---

## Estrutura do Repositório

```
.
├── bootstrap/              # Criação do bucket S3 (backend)
├── terraform/              # Infraestrutura principal (EC2 + Kubernetes)
├── charts/nginx-app        # Helm Chart da aplicação
├── .github/workflows       # Pipeline CI/CD
├── docs/                   # Imagens do projeto
├── README.md
```

---

## Provisionamento da Infraestrutura

### 1. Criar bucket S3 (backend Terraform)

```bash
cd bootstrap
terraform init
terraform apply
```

Copie o valor do output:

```
bucket_name = <nome-gerado>
```

---

### 2. Inicializar Terraform com backend remoto

```bash
cd ../terraform

terraform init \
  -backend-config="bucket=<nome-do-bucket>"
```

---

### 3. Provisionar infraestrutura

```bash
terraform apply
```

Isso irá criar automaticamente:

* EC2 com Docker, Minikube, Kubectl e Helm
* Key Pair gerada automaticamente
* Security Group
* Cluster Kubernetes pronto para uso

---

## Autenticação (OIDC)

O projeto utiliza autenticação via OIDC no GitHub Actions.

* O GitHub assume uma role IAM na AWS
* A trust policy restringe o acesso ao repositório

### Benefícios

* Maior segurança
* Sem vazamento de credenciais
* Sem uso de access keys

---

## Pipeline CI/CD

O pipeline executa automaticamente a cada push na branch `main`.

### Etapas

1. Validação do Helm Chart (`helm lint`)
2. Autenticação na AWS via OIDC
3. Conexão SSH com a EC2
4. Deploy com Helm

```bash
helm upgrade --install nginx .
```

---

## Aplicação

A aplicação consiste em um Nginx com conteúdo dinâmico.

A mensagem exibida é injetada via Helm:

```bash
--set message="Hello World da AsapTech - Deploy realizado via CI/CD (Commit: <SHA>)"
```

---

## Validação

### 1. Acessar a EC2

```bash
terraform output -raw private_key > k8s-key.pem
chmod 600 k8s-key.pem

ssh -i k8s-key.pem ec2-user@$(terraform output -raw public_ip)
```

---

### 2. Verificar cluster Kubernetes

```bash
kubectl get nodes
```

Saída esperada:

```
minikube   Ready
```

---

### 3. Verificar pods

```bash
kubectl get pods
```

---

### 4. Acessar aplicação

```bash
kubectl port-forward svc/nginx 8080:80
```

Abra no navegador:

```
http://localhost:8080
```

---

## Acesso remoto via túnel SSH

```bash
ssh -i k8s-key.pem -L 8080:localhost:8080 ec2-user@<EC2_PUBLIC_IP>
```

---

## Evidências

### Bucket S3 (Terraform State)

![S3 Bucket](./docs/s3-bucket.png)

---

### Deploy via CI/CD

![Deploy](./docs/deploy.png)

---

## Conclusão

Este projeto foi desenvolvido com foco em reprodutibilidade, automação e boas práticas de DevOps, garantindo que toda a infraestrutura possa ser provisionada em qualquer conta AWS sem necessidade de configurações manuais.
