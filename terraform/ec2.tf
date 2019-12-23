data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-x86_64-gp2"]
  }
}
resource "aws_security_group" "ssh_sg" {
  name        = "web-sg"
  description = "SSH from 0.0.0.0/0 is bad"
  vpc_id      = aws_vpc.this.id
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_network_interface" "ni" {
  subnet_id   = aws_subnet.public.id
  private_ips = ["10.0.1.10"]
  tags = {
    Name = "ネットワークインターフェイス"
  }
  security_groups = [
    aws_security_group.ssh_sg.id,
  ]
}
resource "aws_key_pair" "auth" {
  key_name   = "hogehoge-pubkey"
  public_key = file("./hogehoge.pub")
}
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  tenancy       = "default"
  key_name      = aws_key_pair.auth.id
  user_data     = <<EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y httpd
    sudo chkconfig httpd on
    sudo service start httpd
  EOF
  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }
  network_interface {
    network_interface_id = aws_network_interface.ni.id
    device_index         = 0
  }
  tags = {
    Name = "Webサーバー"
  }
}
