data "aws_eip" "sepolia_eip" {
  id = "eipalloc-09f5dec9a034f52bc"
}

resource "aws_security_group" "sepolia" {
  name = "sepolia-allowall"
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

resource "aws_eip_association" "sepolia_assoc" {
  instance_id = aws_instance.sepolia_sync.id
  allocation_id = data.aws_eip.sepolia_eip.id
}

resource "aws_volume_attachment" "att" {
  device_name = "/dev/sdz"
  volume_id = "vol-0ff84c693c671446e"
  instance_id = aws_instance.sepolia_sync.id
}

resource "aws_instance" "sepolia_sync" {
  ami = var.instance_ami
  key_name = var.key_pair_name
  availability_zone = "eu-west-3a"

  instance_type = "c5.xlarge"

  vpc_security_group_ids = [aws_security_group.sepolia.id]

  root_block_device {
    volume_size = 40
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
    Name = "sepolia"
  }
}
