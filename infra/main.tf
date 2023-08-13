provider "aws" {
  region  = "us-east-1"
  profile = "default"
  default_tags {
    tags = {
      Organisation = "Asmigar"
      Environment  = "dev"
    }
  }
}

data "http" "my_public_ip" {
  url = "https://ifconfig.me"
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["${data.http.my_public_ip.response_body}/32"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "http"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "docker swarm"
    from_port   = 2377
    to_port     = 2377
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = "docker_swarm"
  public_key = tls_private_key.this.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.this.private_key_openssh}' > ~/.ssh/${self.key_name}.pem; chmod 400 ~/.ssh/${self.key_name}.pem"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf ~/.ssh/${self.key_name}.pem"
  }
}

resource "aws_instance" "manager" {
  ami           = "ami-022e1a32d3f742bd8"
  instance_type = var.instance_type

  tags = {
    Name = "manager"
  }

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  subnet_id              = aws_subnet.public.id
  key_name               = aws_key_pair.this.key_name
  user_data              = <<-EOT
		#!/bin/bash
		yum update -y
		yum install -y docker
		systemctl start docker
		systemctl enable docker
		usermod -a -G docker ec2-user
        docker swarm init
		EOT
}


resource "aws_instance" "worker" {
  count         = var.enable_workers ? 2 : 0
  ami           = "ami-022e1a32d3f742bd8"
  instance_type = var.instance_type

  tags = {
    Name = "worker-${count.index}"
  }

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  subnet_id              = aws_subnet.public.id
  key_name               = aws_key_pair.this.key_name
  user_data              = <<-EOT
		#!/bin/bash
		yum update -y
		yum install -y docker
		systemctl start docker
		systemctl enable docker
		usermod -a -G docker ec2-user
		EOT
}
