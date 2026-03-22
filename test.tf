provider "aws" {
  region = "ap-south-1"
}

# VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "My-VPC"
  }
}

# Subnet
resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "My-IGW"
  }
}

# Route Table (VERY IMPORTANT - you missed this 🔥)
resource "aws_route_table" "my_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

# Route Table Association
resource "aws_route_table_association" "my_rta" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_rt.id
}

# Security Group
resource "aws_security_group" "web_sg" {
  name   = "allow_http_https"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    description = "HTTP Access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS Access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH Access"
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

#S3 Bucket for logs
resource "aws_s3_bucket" "log_bucket" {
  bucket = "my-terraform-log-bucket-12345" # must be globally unique

  tags = {
    Name = "Log-Bucket"
  }
}

# EC2 Instance
resource "aws_instance" "web_server" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t2.micro"

  subnet_id                   = aws_subnet.my_subnet.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y nginx awscli

              systemctl start nginx
              systemctl enable nginx

              echo "Hello from Scalable Infra" > /var/www/html/index.html

              # Copy logs to S3 every 1 min
              echo "* * * * * root aws s3 cp /var/log/nginx/access.log s3://my-terraform-log-bucket-12345/" >> /etc/crontab
              EOF

  tags = {
    Name = "Web-Server"
  }
}