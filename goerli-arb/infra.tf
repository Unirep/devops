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
  instance_id = aws_instance.ebs_sync.id
  allocation_id = data.aws_eip.goerli_arb_eip.id
}

resource "aws_volume_attachment" "att" {
  device_name = "/dev/sdz"
  volume_id = "vol-08c1e72b78d2757c6"
  instance_id = aws_instance.ebs_sync.id
}

resource "aws_instance" "ebs_sync" {
  ami = var.instance_ami
  key_name = var.key_pair_name
  availability_zone = "eu-west-3c"

  instance_type = "c5.2xlarge"

  vpc_security_group_ids = [aws_security_group.goerli_arb.id]

  root_block_device {
    volume_size = 20
  }

  /*
  ebs_block_device {
    device_name = "/dev/sdz"
    snapshot_id = "snap-06444e1cea45ab166"
    volume_type = "io2"
    volume_size = 1000
    iops = 50000
  }
*/
  user_data = templatefile("./cloud-init-ebs.tftpl", {})

  tags = {
    Name = "unirep-goerli-ingress"
  }
}
