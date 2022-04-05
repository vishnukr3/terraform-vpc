#define custom vpc

resource "aws_vpc" "default" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = "true"

    tags = {
        Name = "VKR_custom_vpc"
    }
  
}

#define public subnet

resource "aws_subnet" "public-subnet" {
    vpc_id = "${aws_vpc.default.id}"
    cidr_block = "${var.public_subnet_cidr}"
    availability_zone = "us-east-1a"

    tags = {
        Name = "public_subnet"
    }
     
}

#define private subnet

resource "aws_subnet" "private-subnet" {
    vpc_id = "${aws_vpc.default.id}"
    cidr_block = "${var.private_subnet_cidr}"
    availability_zone = "us-east-1b"
      
}

#define internet gateway

resource "aws_internet_gateway" "MyGW" {
    vpc_id = "${aws_vpc.default.id}"
    
    tags = {
        Name = "MyGW"
    }
}

#define route table

resource "aws_route_table" "WebServer_Route" {
    vpc_id = "${aws_vpc.default.id}"

route {
  cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.MyGW.id}"
} 

tags = {
  Name = "public route"
}
  
}

#define public subnet on WebServer_route

resource "aws_route_table_association" "public_route" {
    subnet_id = "${aws_subnet.public-subnet.id}"
    route_table_id = "${aws_route_table.WebServer_Route.id}"
  
}

#define sec grp for public subnet

resource "aws_security_group" "WebSG" {
    ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    vpc_id = "${aws_vpc.default.id}"

    tags = {
        Name = "WebSG"
    }  
  
}

#define sec grp for private subnet

resource "aws_security_group" "DbSG" {
     ingress {
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    vpc_id = "${aws_vpc.default.id}"

    tags = {
      "Name" = "DbSG"
    }
  
}