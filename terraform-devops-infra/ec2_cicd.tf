data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Jenkins Instance
resource "aws_instance" "jenkins" {
  count                  = var.enable_jenkins ? 1 : 0
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name               = var.key_name != "" ? var.key_name : null
  user_data              = file("${path.module}/scripts/jenkins_tools_setup.sh")

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.project_name}-jenkins"
  }
}

# SonarQube Instance
resource "aws_instance" "sonarqube" {
  count                  = var.enable_sonarqube ? 1 : 0
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.public[1].id
  vpc_security_group_ids = [aws_security_group.sonarqube_sg.id]
  key_name               = var.key_name != "" ? var.key_name : null
  user_data              = file("${path.module}/scripts/sonarqube_setup.sh")

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.project_name}-sonarqube"
  }
}
