data "aws_eip" "goerli_arb_eip" {
  id = "eipalloc-0aad8dc7e746f63d4"
}

resource "aws_security_group" "goerli_arb" {
  name = "goerli-arb-allowall"
  description = "Allow all traffic"

  ingress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip_association" "goerli_arb_assoc" {
  instance_id = aws_instance.unirep_goerli_arb.id
  allocation_id = data.aws_eip.goerli_arb_eip.id
}

resource "aws_instance" "unirep_goerli_arb" {
  ami = var.instance_ami
  key_name = var.key_pair_name

  instance_type = "i3.xlarge"

  vpc_security_group_ids = [aws_security_group.goerli_arb.id]

  root_block_device {
    volume_size = 50
  }

  user_data = templatefile("./cloud-init.tftpl", {})

  tags = {
    Name = "unirep-goerli-arb"
    Creator = "terraform"
  }
}

resource "aws_instance" "ingress" {
  ami = var.instance_ami
  key_name = var.key_pair_name

  instance_type = "t3.small"

  vpc_security_group_ids = [aws_security_group.goerli_arb.id]

  root_block_device {
    volume_size = 20
  }

  tags = {
    Name = "unirep-goerli-ingress"
  }
}
