provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
	ami = "ami-40d28157"
	instance_type = "t2.micro"
	vpc_security_group_ids = ["${aws_security_group.instance.id}"]


	user_data = <<-EOF
				#!/bin/bash
				echo "I"m Up > index.html
				nohup busybox httpd -f -p "${var.server_port}" &
				EOF	

	tags = {
		Name = "terraform-example"
	}
}

resource "aws_security_group" "instance" {
	name = "terraform-example-sg"

	ingress {
		from_port = "${var.server_port}"
		to_port = "${var.server_port}"
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

variable "server_port" {
	description = "web server listening port"
	default = 8080
}

output "public_ip" {
	value = "${aws_instance.example.public_ip}"
}

resource "aws_launch_configuration" "example"{
	image_id = "ami-40d28157"
	instance_type = "t2.micro"
	security_groups = ["{aws_security_group.instance.id}"]

	user_data = <<-EOF
				#!/bin/bash
				echo "I'm Up" > index.html
				nohup busybox httpd -f -p "${var.server_port}" &
				EOF		
	lifecycle {
		create_before_destroy = true
	}
}