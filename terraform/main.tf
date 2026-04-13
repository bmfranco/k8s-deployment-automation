terraform {
  backend "s3" {
    bucket = "k8s-deployment-automation-tf-state-bfranco"
    key    = "k8s/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "k8s_sg" {
  name = "k8s-sg"

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
  instance_type = "t3.small"

  key_name = var.key_name

  vpc_security_group_ids = [aws_security_group.k8s_sg.id]

  user_data = file("user_data.sh")

  tags = {
    Name = "k8s-ec2"
  }
}