#Define Variables for VPC

variable "aws_region" {
    description = "region to deploy EC2"
    default = "us-east-1"
}

variable "aws_ami" {
    description = "ami to use ec2 to launch"
    default = "ami-04505e74c0741db8d"
}

variable "key_path" {
    description = "key path used to fetch the private key"
    default = "Universal_key"
}

variable "key_name" {
    description = "the name of the key"
    default = "Universal_key"
}

variable "vpc_cidr" {
    description = "cidr notation for our custom vpc"
    default = "10.0.0.0/16"  
}

variable "public_subnet_cidr" {
    description = "cidr notation for our public subnet"
    default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
    description = "cidr notation for our private subnet"
    default = "10.0.2.0/24"
}


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
