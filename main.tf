provider "aws" {
  region = var.awsRegion
}
resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpcCidr
  tags = {
    Name = var.vpcName
  }
}

resource "aws_subnet" "subnet" {
  count      = length(var.subnetsCidr)
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.subnetsCidr[count.index]
  tags = {
    Name = var.subnetsNames[count.index]
  }
}


resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = var.igwName
  }
}

resource "aws_route_table" "public_subnet_my_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = var.anyIP
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = var.publicRouteTableName
  }
}
resource "aws_route_table_association" "link_route_table" {
  subnet_id      = aws_subnet.subnet[0].id
  route_table_id = aws_route_table.public_subnet_my_route_table.id
}


resource "aws_eip" "my_eip" {
  vpc = aws_vpc.main_vpc.id
}


resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.my_eip.id
  subnet_id     = aws_subnet.subnet[0].id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = var.anyIP
    nat_gateway_id = aws_nat_gateway.my_nat_gateway.id
  }
}

resource "aws_route_table_association" "link_route_table2" {
  subnet_id      = aws_subnet.subnet[1].id
  route_table_id = aws_route_table.private_route_table.id
}


resource "aws_security_group" "ssh_http_security_group" {
  name        = "ssh_http_security_group"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = aws_vpc.main_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.anyIP]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.anyIP]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.anyIP]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
}

resource "aws_instance" "ec2_public" {
  associate_public_ip_address = true
  instance_type               = var.instanceType
  subnet_id                   = aws_subnet.subnet[0].id
  ami                         = data.aws_ami.ubuntu.id
  security_groups             = [aws_security_group.ssh_http_security_group.id]
  user_data                   = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y apache2
    systemctl start apache2
    systemctl enable apache2
  EOT
  tags = {
    Name = "public ec2"
  }
}

resource "aws_instance" "ec2_private" {
  associate_public_ip_address = true
  instance_type               = var.instanceType
  subnet_id                   = aws_subnet.subnet[1].id
  ami                         = data.aws_ami.ubuntu.id
  security_groups             = [aws_security_group.ssh_http_security_group.id]
  user_data                   = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y apache2
    systemctl start apache2
    systemctl enable apache2
  EOT
  tags = {
    Name = "private ec2"
  }
}
