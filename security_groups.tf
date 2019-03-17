resource "aws_security_group" "allow_ssh" {
	name = "allow_ssh"
	description = "Allow inbound SSH traffic from my IP"
	vpc_id = "${aws_vpc.default.id}"

	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

	tags {
		Name = "Allow SSH"
	}
}

resource "aws_security_group" "master-api" {
	name = "API"
	description = "Kubernetes master API"
	vpc_id = "${aws_vpc.default.id}"

	ingress {
		from_port = 6433
		to_port = 6433
		protocol = "tcp"
		cidr_blocks = ["10.0.1.0/24"]
	}

	tags {
		Name = "Kubernetes API"
	}
}