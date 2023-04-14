resource "aws_security_group" "unirep_http_sg" {
  name = "unirep-http-ssh"
  description = "Allow http/ssh traffic"

  ingress {
    from_port = "80"
    to_port = "80"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = "443"
    to_port = "443"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    self = true
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "unirep_sg" {
  name = "unirep-allowall"
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

resource "aws_db_instance" "unirep_rancher_db" {
  vpc_security_group_ids = [aws_security_group.unirep_sg.id]
  allocated_storage = 100
  db_name = "unirep"
  engine = "mysql"
  instance_class = "db.m5.large"
  username = "admin"
  password = var.mysql_password
  skip_final_snapshot = true
  identifier = "unirep-terraform"
  tags = {
    Name = "unirep-rancher-db"
    Creator = "terraform"
  }
}

resource "aws_eip_association" "devops_eip_assoc" {
  instance_id = aws_instance.unirep_rancher_server.id
  allocation_id = "eipalloc-035f8ce4f49d02934"
}

resource "aws_instance" "unirep_rancher_server" {
  ami = var.instance_ami

  vpc_security_group_ids = [aws_security_group.unirep_http_sg.id]

  instance_type = var.instance_type
  key_name = var.key_pair_name

  root_block_device {
    volume_size = 40
  }

  user_data = templatefile("./rancher-server-init.tftpl", {
    kubernetes_version = var.kubernetes_version
    cert_manager_version = var.cert_manager_version
    rancher_server_admin_password = var.rancher_server_admin_password
    mysql_password = var.mysql_password
    mysql_host = aws_db_instance.unirep_rancher_db.endpoint
    develop_kubernetes_token = var.develop_kubernetes_token
  })

  tags = {
    Name = "unirep-rancher-server"
    Creator = "terraform"
  }
}

resource "aws_instance" "unirep_rancher_node" {
  count = 2

  ami = var.instance_ami

  vpc_security_group_ids = [aws_security_group.unirep_http_sg.id]

  instance_type = var.instance_type
  key_name = var.key_pair_name

  associate_public_ip_address = true

  root_block_device {
    volume_size = 80
  }

  user_data = templatefile("./rancher-node-init.tftpl", {
    kubernetes_version = var.kubernetes_version
    develop_kubernetes_token = var.develop_kubernetes_token
  })

  tags = {
    Name = "unirep-rancher-node-${count.index}"
    Creator = "terraform"
  }
}
