provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "autovpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    "Name" = var.vpc_name
  }
}

resource "aws_subnet" "autopublicsubnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.autovpc.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = element(var.az, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.vpc_name}-Public-Subnet-${count.index + 1}"
  }
}
resource "aws_internet_gateway" "autoIGW" {
  vpc_id = aws_vpc.autovpc.id
  tags = {
    Name = "${var.vpc_name}-igw"
  }
}
resource "aws_route_table" "autopublicroute" {
  vpc_id = aws_vpc.autovpc.id
  tags = {
    Name = "${var.vpc_name}-PublicRoute"
  }
  route {
    gateway_id = aws_internet_gateway.autoIGW.id
    cidr_block = "0.0.0.0/0"
  }
}

resource "aws_route_table_association" "public_route_association" {
  count          = length(var.public_subnet_cidrs)
  route_table_id = aws_route_table.autopublicroute.id
  subnet_id      = element(aws_subnet.autopublicsubnets.*.id, count.index)
}

resource "aws_security_group" "autosg" {
  vpc_id      = aws_vpc.autovpc.id
  name        = "websecurity"
  description = "Secure all the web app ports"
  tags = {
    "Name" = "Dev-SG"
  }
  lifecycle {
    ignore_changes = [
      ingress,
      egress,
    ]
  }
}
resource "aws_vpc_security_group_ingress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.autosg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.autosg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_instance" "demoinstance" {
  count = var.env == "Dev" ? 2:1
  ami = var.ami
  instance_type = "t2.micro"
  key_name = var.key_name
  subnet_id = element(aws_subnet.autopublicsubnets.*.id, count.index)
  vpc_security_group_ids = [ aws_security_group.autosg.id ]
  tags = {
    Name = "${var.vpc_name}-Publicserver-${count.index + 1}"
  }
}
