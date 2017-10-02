provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "/${var.home}/.aws/credentials-${var.project_name}"
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.project_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "default" {
  ami           = "ami-46c1b650"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  subnet_id = "${aws_subnet.default.id}"
  associate_public_ip_address = true
  key_name = "${aws_key_pair.auth.id}"

  tags {
    Name = "${var.project_name}"
  }

  connection {
    user = "centos"
    private_key = "${file(var.private_key_path)}"
  }

  root_block_device {
    volume_size =  20
    delete_on_termination = "true"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y git",
      "sudo git clone ${var.repository} /opt/${var.project_name}",
      "cd /opt/${var.project_name} && sudo git checkout ${var.branch}",
      "cd /opt/${var.project_name} && sudo bash -x ./install.sh -p ${var.project_name} -a ${var.owncloud_admin_pass} -d ${aws_instance.default.public_dns}"
    ]
  }
}

resource "aws_vpc" "default" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "default" {
  name        = "${var.project_name}"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "ready" {
  value = "Please login on https://${aws_instance.default.public_dns} with admin/${var.owncloud_admin_pass}"
}
