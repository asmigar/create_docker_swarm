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

resource "aws_security_group" "allow_ssh" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "http"
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "docker swarm"
    from_port        = 2377
    to_port          = 2377
    protocol         = "tcp"
    cidr_blocks      = [aws_subnet.public.cidr_block]
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

  provisioner "local-exec" {
    command = "echo '${self.private_key_openssh}' > ~/.ssh/docker_swarm.pem; chmod 400 ~/.ssh/docker_swarm.pem"
  }

  provisioner "local-exec" {
    when = destroy
    command = "rm -rf ~/.ssh/docker_swarm.pem"
  }
}

resource "aws_key_pair" "this" {
  key_name   = "docker_swarm"
  public_key = tls_private_key.this.public_key_openssh
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
		curl -SL https://github.com/docker/compose/releases/download/v2.19.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
		chmod +x /usr/local/bin/docker-compose
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
		curl -SL https://github.com/docker/compose/releases/download/v2.19.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
		chmod +x /usr/local/bin/docker-compose
		EOT
}
