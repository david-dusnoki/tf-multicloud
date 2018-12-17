data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-*-16.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
    ami           = "${data.aws_ami.ubuntu.id}"
    instance_type = "t2.micro"

    tags = {
        Name = "Test"
    }
}

resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    tags {
        Name = "${var.name}-vpc"
    }
}

/*
    Internet Gateway
*/

resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.vpc.id}"
    tags {
        Name = "igw-${var.name}"
    }
}

/*
    Internet Gateway Routing
*/

resource "aws_route" "internet_access" {
    route_table_id         = "${aws_vpc.vpc.main_route_table_id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = "${aws_internet_gateway.igw.id}"
}

/*
    Public Subnet
*/

resource "aws_subnet" "sub_pub" {
    vpc_id                      = "${aws_vpc.vpc.id}"
    cidr_block                  = "10.0.0.0/24"
    availability_zone           = "us-west-1b"
    map_public_ip_on_launch     = true

    tags {
        Name = "Public Subnet ${var.name}"
    }
}

/*
    Public Route Table
*/

resource "aws_route_table" "pub_rt" {
    vpc_id = "${aws_vpc.vpc.id}"

 
tags {
        Name = "Public ${var.name} route table"
    }
}

resource "aws_route" "pub_route" {
    route_table_id  = "${aws_route_table.pub_rt.id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
}
