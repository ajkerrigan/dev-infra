data "aws_ami" "selected" {
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["801119661308"]
}

variable "vpc_id" {
  type = string
}

locals {
  vpc_id = var.vpc_id
  tags = {
    Environment = "dev"
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = local.vpc_id

  tags = {
    Name = "*private*"
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = local.vpc_id

  tags = {
    Name = "*public*"
  }
}

resource "aws_instance" "private" {
  ami           = data.aws_ami.selected.id
  instance_type = "t3.micro"
  subnet_id   = tolist(data.aws_subnet_ids.private.ids)[0]
  tags = local.tags
}

resource "aws_instance" "public" {
  ami           = data.aws_ami.selected.id
  instance_type = "t3.micro"
  subnet_id   = tolist(data.aws_subnet_ids.public.ids)[0]
  tags = local.tags
}
