resource "aws_instance" "web-2" {
    count = "${var.env == "dev" ? 1 : 5}"
    ami = "${lookup(var.amis, var.aws_region)}"
    availability_zone = "${element(var.azs, count.index)}"
    instance_type = "t2.micro"
    key_name = "${var.key_name}"
    subnet_id = "${element(aws_subnet.allsubnets.*.id, count.index)}"
    vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]
    associate_public_ip_address = true	
    tags {
        Name = "Server-${count.index}"
        Env = "${var.env}"
        Owner = "Sree"
    }
}