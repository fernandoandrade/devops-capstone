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

resource "aws_key_pair" "infra-server-key_pair" {
  key_name   = "infra-server-key"
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

resource "aws_security_group" "bsf-infra-sg" {
  name = "BSF-INFRA-SG"
  description = "BSF Infra security group"

  tags = {
    Name = "BSF-INFRA-SG"
    Environment = terraform.workspace
  }
}

resource "aws_security_group_rule" "create-infra-sgr-ssh" {
  security_group_id = aws_security_group.bsf-infra-sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  protocol          = "tcp"
  to_port           = 22
  type              = "ingress"
}

resource "aws_security_group_rule" "create-infra-sgr-inbound" {
  security_group_id = aws_security_group.bsf-infra-sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "all"
  to_port           = 65535
  type              = "ingress"
}

resource "aws_security_group_rule" "create-infra-sgr-outbound" {
  security_group_id = aws_security_group.bsf-infra-sg.id
  cidr_blocks         = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "all"
  to_port           = 65535
  type              = "egress"
}

resource "aws_instance" "infra-server" {
  count = 1
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.infra-server-key_pair.key_name
  security_groups = ["BSF-INFRA-SG"]
  tags = {
    Name = "bsf-infra"
  }
}

resource "null_resource" "infra-server-conf" {
    
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.private-key.private_key_pem
    host        = aws_instance.infra-server.*.public_dns[0]
  }
  
  provisioner "file" {
    source      = "variables.tf"
    destination = "/tmp/variables.tf"
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo apt update ",
      "echo Ansible",
      "sudo apt install -y software-properties-common ",
      "sudo add-apt-repository --yes --update ppa:ansible/ansible ",
      "sudo apt install ansible -y ",
      "echo '[webservers]' > ~/hosts",
      "echo '${aws_instance.infra-server.*.public_dns[0]}' >> ~/hosts",
      "echo '${tls_private_key.private-key.private_key_pem}' > ~/.ssh/bsf-infra.pem && chmod 600 ~/.ssh/bsf-infra.pem",
      "sudo sed -i '71s/.*/host_key_checking = False/' /etc/ansible/ansible.cfg",
      "echo Install Java"
    ]
  }

  provisioner "local-exec" {
    command = "mkdir -p ~/.ssh && echo '${tls_private_key.private-key.private_key_pem}' > ~/.ssh/bsf-infra.pem && chmod 600 ~/.ssh/bsf-infra.pem "
  }
}
