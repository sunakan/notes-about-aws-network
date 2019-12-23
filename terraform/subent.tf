resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.this.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "パブリックサブネット"
  }
}
