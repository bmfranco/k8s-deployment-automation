# Kubernetes Deployment Automation

Este projeto demonstra a criação de uma infraestrutura automatizada e reproduzível na AWS, utilizando Terraform, Kubernetes (Minikube), Helm e GitHub Actions com runner self-hosted.

---

## Tecnologias Utilizadas

![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4?style=for-the-badge&logo=terraform)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Orchestration-326CE5?style=for-the-badge&logo=kubernetes)
![Helm](https://img.shields.io/badge/Helm-Package_Manager-0F1689?style=for-the-badge&logo=helm)
![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?style=for-the-badge&logo=amazonaws)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI/CD-2088FF?style=for-the-badge&logo=githubactions)
![Docker](https://img.shields.io/badge/Docker-Container-2496ED?style=for-the-badge&logo=docker)

---

## Pré-requisitos

Antes de iniciar, certifique-se de que possui os seguintes itens configurados:

### Ferramentas

- AWS CLI 
- Terraform 
- Git
- Bash ou terminal compatível

### Configuração da AWS

- Conta ativa na AWS  
- Credenciais configuradas via AWS CLI:

    aws configure

Ou via variáveis de ambiente:

    export AWS_ACCESS_KEY_ID=<SUA_ACCESS_KEY>
    export AWS_SECRET_ACCESS_KEY=<SUA_SECRET_KEY>
    export AWS_DEFAULT_REGION=us-east-1

### Permissões necessárias

O usuário/role da AWS deve possuir permissões para:

- EC2 (criação e gerenciamento de instâncias)
- IAM (criação de roles e policies)
- S3 (criação e gerenciamento de buckets)
- SSM (acesso à instância via Session Manager)

---

## Explicação do projeto

### Arquitetura

- EC2 provisionada via Terraform  
- Cluster Kubernetes com Minikube inicializado via user_data  
- Runner self-hosted do GitHub Actions executando na EC2  
- Deploy automatizado via Helm  
- Backend remoto do Terraform em S3 com versionamento  

---

### Estrutura do projeto

    .
    ├── .github/             # Configuração do GitHub Actions
    ├── bootstrap/           # Criação do bucket S3 (backend Terraform)
    ├── charts/              # Helm Charts (nginx-app)
    ├── terraform/           # Infraestrutura principal (EC2 + Kubernetes)
    ├── docs/                # Evidências do projeto
    ├── .gitignore
    └── README.md

---

### Autenticação com OIDC

O projeto utiliza OIDC (OpenID Connect) para autenticação entre GitHub Actions e AWS.

Funcionamento:

- O GitHub Actions solicita um token OIDC temporário  
- A AWS valida esse token  
- O pipeline assume uma role IAM  
- Não há uso de Access Keys ou Secrets  

Benefícios:

- Maior segurança  
- Eliminação de credenciais fixas  
- Integração nativa com AWS  

Restrição configurada:

    repo:<SEU_USUARIO>/<SEU_REPOSITORIO>:*

---

### Pipeline CI/CD

Etapas do pipeline:

1. Checkout do código  
2. Aguardar inicialização do Minikube  
3. Validação do Helm Chart (`helm lint`)  
4. Deploy da aplicação via Helm  

    helm upgrade --install nginx .

---

### Decisão arquitetural

O Terraform não é executado dentro do pipeline.

Motivo:

- O runner está hospedado na própria EC2 provisionada  
- Executar Terraform poderia destruir a instância em uso  

Solução adotada:

- Terraform → provisionamento manual  
- CI/CD → apenas deploy da aplicação  

---

### Aplicação

A aplicação é um Nginx configurado via Helm.

Mensagem dinâmica:

    --set message="Hello World - Deploy realizado via CI/CD (Commit: <SHA>)"

---

## Como utilizar o projeto

### 1. Clonar o repositório

    git clone https://github.com/<SEU_USUARIO>/<SEU_REPOSITORIO>.git
    cd <SEU_REPOSITORIO>

---

### 2. Criar bucket S3 (backend do Terraform)

    cd bootstrap
    terraform init
    terraform apply

Copie o output:

    bucket_name = <nome-do-bucket>

---

### 3. Inicializar Terraform com backend remoto

    cd ../terraform

    terraform init \
      -backend-config="bucket=<nome-do-bucket>"

---

### 4. Configurar variáveis do Terraform

Crie o arquivo:

    terraform/terraform.tfvars

Conteúdo:

    github_repo = "<SEU_USUARIO>/<SEU_REPOSITORIO>"

---

### 5. Gerar token do GitHub (runner)

No repositório:

1. Acesse **Settings**
2. Vá em **Actions → Runners**
3. Clique em **New self-hosted runner**
4. Copie o token

⚠️ O token expira em poucos minutos.

---

### 6. Provisionar infraestrutura

    terraform apply -var="github_runner_token=<SEU_TOKEN>"

Isso irá criar automaticamente:

- EC2 com Docker, Minikube, Kubectl e Helm  
- Runner self-hosted configurado automaticamente  
- Cluster Kubernetes pronto para uso  

---

### 7. Configurar variáveis no GitHub

No repositório:

1. Acesse **Settings**
2. Vá em **Secrets and variables → Actions → Variables**
3. Crie a seguinte variável:

    AWS_ROLE_ARN = arn:aws:iam::<ACCOUNT_ID>:role/github-actions-role

Esse valor é obtido no output do Terraform:

    github_actions_role_arn = "arn:aws:iam::<ACCOUNT_ID>:role/github-actions-role"

---

### 8. Executar o pipeline

#### Automático (push na branch main)

    git add .
    git commit -m "trigger pipeline"
    git push

#### Manual (via interface do GitHub)

- Acesse **Actions**
- Selecione o workflow **Deploy**
- Clique em **Run workflow**

---

### 9. Validar a aplicação

Acesse a EC2 via SSM:

    aws ssm start-session --target <INSTANCE_ID>

Verificar cluster:

    kubectl get nodes

Verificar pods:

    kubectl get pods

Executar port-forward:

    kubectl port-forward svc/nginx 8080:80

Em outro terminal:

    curl localhost:8080

Saída esperada:

    <html>
      <body>
        <h1>Hello World da AsapTech - Deploy realizado via CI/CD (Commit: ...)</h1>
      </body>
    </html>

---

## Evidências

### Backend Terraform (S3)

![S3 Bucket](./docs/s3-bucket.png)

---

### Pipeline CI/CD

![Pipeline Deploy](./docs/deploy.png)

---