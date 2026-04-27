terraform {
  backend "s3" {
    key    = "k8s/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

# gerar sufixo unico
resource "random_id" "suffix" {
  byte_length = 4
}

# gerar chave SSH
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# registrar key pair na AWS 
resource "aws_key_pair" "generated_key" {
  key_name   = "k8s-key-${random_id.suffix.hex}"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "aws_security_group" "k8s_sg" {
  name = "k8s-sg-${random_id.suffix.hex}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "k8s" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t3.medium"

  key_name = aws_key_pair.generated_key.key_name

  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.k8s_sg.id]

  user_data = file("user_data.sh")

  tags = {
    Name = "k8s-ec2"
  }
}