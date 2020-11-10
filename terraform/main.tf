provider "aws" {
  profile                 = "default"
  region                  = "us-west-1"

  assume_role {
    role_arn    = "arn:aws:iam::693598974269:role/EC2_Admin"
  }
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

resource "aws_vpc" "prod_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production_vpc"
  }
}

resource "aws_internet_gateway" "prod_gw" {
  vpc_id = aws_vpc.prod_vpc.id

  tags = {
    Name = "production_gateway"
  }
}

resource "aws_route_table" "prod_rt" {
  vpc_id = aws_vpc.prod_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod_gw.id
  }

  tags = {
    Name = "production_route_table"
  }
}

variable "subnet_1_cidr_block" {
  type    = string
  default = "10.0.1.0/24"
}

resource "aws_subnet" "prod_subnet_1" {
  vpc_id            = aws_vpc.prod_vpc.id
  cidr_block        = var.subnet_1_cidr_block
  availability_zone = "us-west-1a"

  tags = {
    Name = "production_subnet_1"
  }
}

resource "aws_route_table_association" "prod_rt_assoc" {
  subnet_id      = aws_subnet.prod_subnet_1.id
  route_table_id = aws_route_table.prod_rt.id
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.prod_vpc.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from VPC"
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

  tags = {
    Name = "allow_web"
  }
}

variable private_ips {
  type = list(string)
  default = ["10.0.1.50"]
}

resource "aws_network_interface" "prod_nic" {
  subnet_id       = aws_subnet.prod_subnet_1.id
  private_ips     = var.private_ips
  security_groups = [aws_security_group.allow_web.id]
}

resource "aws_eip" "prod_eip" {
  vpc                       = true
  network_interface         = aws_network_interface.prod_nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.prod_gw]
}


resource "aws_instance" "ec2_example" {
  ami               = "ami-0e4035ae3f70c400f"
  instance_type     = "t2.micro"
  availability_zone = "us-west-1a"
  key_name          = "AWSEC2"
  
  network_interface {
    network_interface_id  = aws_network_interface.prod_nic.id
    device_index          = 0
  }

  tags = {
    "Name" = "test_server"
  }
}

output "public_ip" {
  value = aws_instance.ec2_example.public_ip
}