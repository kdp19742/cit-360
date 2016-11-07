# Add your VPC ID to default below
variable "vpc_id" {
  description = "VPC ID for usage throughout the build process"
  default = "vpc-6208fa05"
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${var.vpc_id}"

  tags = {
    Name = "default_ig"
  }
}

resource "aws_eip" "tuto_eip" {
  vpc = true
  depends_on = ["aws_internet_gateway.gw"]
}

resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.tuto_eip.id}"
  subnet_id = "${aws_subnet.public_subnet_a.id}"
  depends_on = ["aws_internet_gateway.gw"]
}

#Public Routing Table

resource "aws_route_table" "public_routing_table" {
  vpc_id = "${var.vpc_id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "public_routing_table"
  }
}

#Public Subnets

resource "aws_subnet" "public_subnet_a" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "172.31.1.0/24"
  availability_zone = "us-west-2a"

  tags {
    Name = "public_a"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "172.31.2.0/24"
  availability_zone = "us-west-2b"

  tags {
    Name = "public_b"
  }
}

resource "aws_subnet" "public_subnet_c" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "172.31.3.0/24"
  availability_zone = "us-west-2c"

  tags {
    Name = "public_c"
  }
}

#Public Routing Table Associations

resource "aws_route_table_association" "public_subnet_a_rt_assoc" {
  subnet_id = "${aws_subnet.public_subnet_a.id}"
  route_table_id = "${aws_route_table.public_routing_table.id}"
}

resource "aws_route_table_association" "public_subnet_b_rt_assoc" {
  subnet_id = "${aws_subnet.public_subnet_b.id}"
  route_table_id = "${aws_route_table.public_routing_table.id}"
}

resource "aws_route_table_association" "public_subnet_c_rt_assoc" {
  subnet_id = "${aws_subnet.public_subnet_c.id}"
  route_table_id = "${aws_route_table.public_routing_table.id}"
}

#Private Routing Table

resource "aws_route_table" "private_routing_table" {
  vpc_id = "${var.vpc_id}"
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.gw.id}"
  }
  tags {
    Name = "private_routing_table"
  }
}

#Private Subnets

resource "aws_subnet" "private_subnet_a" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "172.31.4.0/22"
  availability_zone = "us-west-2a"

  tags {
    Name = "private_a"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "172.31.8.0/22"
  availability_zone = "us-west-2b"

  tags {
    Name = "private_b"
  }
}

resource "aws_subnet" "private_subnet_c" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "172.31.12.0/22"
  availability_zone = "us-west-2c"

  tags {
    Name = "private_c"
  }
}

#Private Routing Table Associations

resource "aws_route_table_association" "private_subnet_a_rt_assoc" {
  subnet_id = "${aws_subnet.private_subnet_a.id}"
  route_table_id = "${aws_route_table.private_routing_table.id}"
}

resource "aws_route_table_association" "private_subnet_b_rt_assoc" {
  subnet_id = "${aws_subnet.private_subnet_b.id}"
  route_table_id = "${aws_route_table.private_routing_table.id}"
}

resource "aws_route_table_association" "private_subnet_c_rt_assoc" {
  subnet_id = "${aws_subnet.private_subnet_c.id}"
  route_table_id = "${aws_route_table.private_routing_table.id}"
}

#Security Group Rules

resource "aws_security_group" "nat" {
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Create EC2 instance

resource "aws_instance" "web" {
  ami ="ami-5ec1673e"
  instance_type = "t2.micro"
  subnet_id  = "${aws_subnet.public_subnet_a.id}"
  vpc_security_group_ids = ["${aws_security_group.nat.id}"]
  associate_public_ip_address = true
  key_name = "cit360"
}


