resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  provider = aws.primary
}
resource "aws_subnet" "public_subnet" {
  provider = aws.primary
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.primary.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}
resource "aws_internet_gateway" "igw" {
  provider = aws.primary
  vpc_id = aws_vpc.main.id
}
resource "aws_route_table" "public_rt" {
  provider = aws.primary

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}
resource "aws_route_table_association" "public_subnet_assoc" {
  provider = aws.primary

  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_security_group" "web_sg" {

  name = "terraform-web-sg"
  vpc_id = aws_vpc.main.id
  provider = aws.primary
  ingress {
from_port   = 22
to_port     = 22
    protocol    = "tcp"
cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
from_port   = 80
to_port     = 80
    protocol    = "tcp"
cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
from_port   = 8080
to_port     = 8080
    protocol    = "tcp"
cidr_blocks = ["0.0.0.0/0"]
  }

  egress {

from_port = 0
to_port   = 0
    protocol  = "-1"

cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "devops_server" {
  provider = aws.primary

ami           = data.aws_ami.ami-primary.id  # Ubuntu 22.04 in ap-south-1 (verify the latest AMI before use)
instance_type = var.instance_type
subnet_id = aws_subnet.public_subnet.id
key_name      = var.key_name
associate_public_ip_address = true

vpc_security_group_ids = [
    aws_security_group.web_sg.id
  ]
 user_data = <<-EOF
              #!/bin/bash

              # Update packages
              apt update -y

              # Install Docker
              apt install docker.io -y
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu

              EOF


  tags = {
    Name = "DevOps-Server"
  }
}

