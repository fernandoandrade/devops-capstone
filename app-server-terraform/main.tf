provider "aws" {
  region                  = "us-east-1"
  access_key              = "${var.access_key}"
  secret_key              = "${var.secret_key}"
  token                   = "${var.session_token}"
}

resource "tls_private_key" "private-key" {
  algorithm   = "RSA"
  rsa_bits    = 2048
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
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

resource "aws_security_group" "bsf-sg" {
  name = "BSF-SG"
  description = "BSF security group"

  tags = {
    Name = "BSF-SG"
    Environment = terraform.workspace
  }
}

resource "aws_security_group_rule" "create-sgr-ssh" {
  security_group_id = aws_security_group.xyz-sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  protocol          = "tcp"
  to_port           = 22
  type              = "ingress"
}

resource "aws_security_group_rule" "create-sgr-inbound" {
  security_group_id = aws_security_group.xyz-sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "all"
  to_port           = 65535
  type              = "ingress"
}

resource "aws_security_group_rule" "create-sgr-outbound" {
  security_group_id = aws_security_group.xyz-sg.id
  cidr_blocks         = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "all"
  to_port           = 65535
  type              = "egress"
}

resource "aws_instance" "jenkins" {
  count         = 1
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  security_groups = ["BSF-SG"]
  tags = {
    Name = "bsf-${count.index}"
  }
}

resource "null_resource" "deploy-server" {
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.private-key.private_key_pem
      host        = aws_instance.jenkins.*.public_dns[0]
    }

    provisioner "remote-exec" {
      inline = [
        "sudo apt update ",
        "sudo apt install -y software-properties-common ",
        "sudo add-apt-repository --yes --update ppa:ansible/ansible ",
        "sudo apt install ansible -y ",
        "echo '[webservers]' > ~/hosts",
        "echo '${aws_instance.web.*.public_dns[1]}' >> ~/hosts",
        "echo '${tls_private_key.private-key.private_key_pem}' > ~/.ssh/xyz.pem && chmod 600 ~/.ssh/xyz.pem",
        "sudo sed -i '71s/.*/host_key_checking = False/' /etc/ansible/ansible.cfg",
        "sudo apt install -y openjdk-11-jdk ",
        "sudo apt-get install -y git",
        "sudo apt-get install -y maven",
        "sudo wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -",
        "sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'",
        "sudo apt update",
        "sudo apt install -y jenkins",
        "sudo systemctl start jenkins",
        "echo 'Java_Home:'",
        "readlink -f $(which java)",
        "echo 'Mvn_Home:'",
        "mvn -v",
        "echo 'Jenkins Initial Admin password:'",
        "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
      ]
    }

    provisioner "local-exec" {
      command = "echo '${tls_private_key.private-key.private_key_pem}' > ~/.ssh/xyz.pem && chmod 600 ~/.ssh/bsf.pem "
    }
}

resource "null_resource" "client-node" {
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.private-key.private_key_pem
      host        = aws_instance.web.*.public_dns[1]
    }

    provisioner "remote-exec" {
      inline = [
        "sudo apt update ",
        "sudo apt install -y software-properties-common ",
	"sudo add-apt-repository --yes --update ppa:linuxuprising/java ",
	"sudo apt install -y openjdk-11-jdk ",
	"sudo apt-cache search tomcat ",
	"sudo apt install -y tomcat9 tomcat9-admin"
      ]
    }

}
