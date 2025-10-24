resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = { Name = "${var.project}-vpc" }
}

resource "aws_subnet" "public" {
  for_each = toset(var.public_subnets)
  vpc_id = aws_vpc.this.id
  cidr_block = each.value
  map_public_ip_on_launch = true
  tags = { Name = "${var.project}-public-${replace(each.value,"/","-")}" }
}

resource "aws_subnet" "private" {
  for_each = toset(var.private_subnets)
  vpc_id = aws_vpc.this.id
  cidr_block = each.value
  tags = { Name = "${var.project}-private-${replace(each.value,"/","-")}" }
}

resource "aws_security_group" "default" {
  name        = "${var.project}-default-sg"
  description = "Default security group for ${var.project}"
  vpc_id      = aws_vpc.this.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "vpc_id" { value = aws_vpc.this.id }
output "public_subnets" { value = values(aws_subnet.public)[*].id }
output "private_subnets" { value = values(aws_subnet.private)[*].id }
output "default_sg_id" { value = aws_security_group.default.id }
