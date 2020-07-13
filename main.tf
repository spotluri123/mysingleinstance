provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
}

resource "aws_vpc" "default" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags {
        Name = "${var.vpc_name}"
    }
}

resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.default.id}"
	tags {
        Name = "${var.IGW_name}"
    }
}

resource "aws_subnet" "allsubnets" {
    count = "${length(var.azs)}"
    vpc_id = "${aws_vpc.default.id}"
    cidr_block = "${element(var.cidrs, count.index)}"
	availability_zone = "${element(var.azs, count.index)}"

    tags {
        Name = "${aws_vpc.default.tags.Name}-Subnet-${count.index}-${var.env}"
    }
	
}

resource "aws_route_table" "terraform-public" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }

    tags {
        Name = "${var.Main_Routing_Table}"
    }
}

resource "aws_route_table_association" "terraform-public" {
   #subnet_id = "${aws_subnet.allsubnets.*.id}"
   count = 6
   subnet_id = "${element(aws_subnet.allsubnets.*.id, count.index)}"
    route_table_id = "${aws_route_table.terraform-public.id}"
   
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    }
}

#resource "aws_instance" "web-1" {
#    count = "${var.env == "dev" ? 1 : 5}"
#    ami = "${lookup(var.amis, var.aws_region)}"
#    availability_zone = "${element(var.azs, count.index)}"
#    instance_type = "t2.micro"
#    key_name = "${var.key_name}"
#    subnet_id = "${element(aws_subnet.allsubnets.*.id, count.index)}"
#    vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]
#    associate_public_ip_address = true	
#    tags {
#        Name = "Server-${count.index}"
#        Env = "${var.env}"
#        Owner = "Sree"
#    }
#}

output "subnets" {
  description = "List of all Subnet IDs"
  value       = ["${aws_subnet.allsubnets.*.id}"]
}

output "cidrs" {
  description = "List of all Subnet CIDRs"
  value       = ["${aws_subnet.allsubnets.*.cidr_block}"]
}

output "subnetsname" {
  description = "Name of all Subnets"
  value       = ["${aws_subnet.allsubnets.*.tags.Name}"]
}

data "aws_ami" "latest" {
  most_recent = true

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["053490018989"]
}
output "latest_ami_name" {
  value = "${data.aws_ami.latest.name}"
}

output "latest_ami_id" {
  value = "${data.aws_ami.latest.id}"
}








