provider "aws" {
  region                  = "us-east-1"
  access_key              = var.access_key
  secret_key              = var.secret_key
  token                   = var.session_token
}

resource "tls_private_key" "private-key" {
  algorithm   = "RSA"
  rsa_bits    = 2048
}

resource "aws_key_pair" "app-server-key_pair" {
  key_name   = "app-server-key"
  public_key = tls_private_key.private-key.public_key_openssh
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "bsf-app-sg" {
  name = "BSF-APP-SG"
  description = "BSF App security group"

  tags = {
    Name = "BSF-APP-SG"
    Environment = terraform.workspace
  }
}

resource "aws_security_group_rule" "create-app-sgr-ssh" {
  security_group_id = aws_security_group.bsf-app-sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  protocol          = "tcp"
  to_port           = 22
  type              = "ingress"
}

resource "aws_security_group_rule" "create-app-sgr-inbound" {
  security_group_id = aws_security_group.bsf-app-sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "all"
  to_port           = 65535
  type              = "ingress"
}

resource "aws_security_group_rule" "create-app-sgr-outbound" {
  security_group_id = aws_security_group.bsf-app-sg.id
  cidr_blocks         = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "all"
  to_port           = 65535
  type              = "egress"
}

resource "aws_instance" "app-server" {
  count         = 1
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.app-server-key_pair.key_name
  security_groups = ["BSF-APP-SG"]
  tags = {
    Name = "bsf-app"
  }
}

resource "null_resource" "app-server-conf" {
    
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.private-key.private_key_pem
    host        = aws_instance.app-server.*.public_dns[0]
  }

  provisioner "remote-exec" {
    inline = [
	"echo Install Docker",
        "sudo apt-get update",
        "sudo apt-get remove docker docker-engine docker.io",
        "sudo apt install docker.io",
        "sudo systemctl start docker",
        "sudo systemctl enable docker",
	"echo '[webservers]' > ~/hosts",
        "echo '${aws_instance.app-server.*.public_dns[0]}' >> ~/hosts"
    ]
  }

  provisioner "local-exec" {
    command = "echo '${tls_private_key.private-key.private_key_pem}' > ~/.ssh/bsf-app.pem && chmod 600 ~/.ssh/bsf-app.pem "
  }
}
