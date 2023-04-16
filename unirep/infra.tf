resource "aws_vpc" "unirep" {
  cidr_block = "172.0.0.0/16"
  tags = {
    Name = "unirep"
  }
}

resource "aws_internet_gateway" "unirep_gateway" {
  vpc_id = aws_vpc.unirep.id
  tags = {
    Name = "unirep"
  }
}

resource "aws_route_table" "unirep_rt" {
  vpc_id = aws_vpc.unirep.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.unirep_gateway.id
  }
}

resource "aws_main_route_table_association" "unirep_rta" {
  vpc_id = aws_vpc.unirep.id
  route_table_id = aws_route_table.unirep_rt.id
}

resource "aws_security_group" "unirep_http_sg" {
  name = "unirep-http-ssh"
  description = "Allow http/ssh traffic"
  vpc_id = aws_vpc.unirep.id

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
  vpc_id = aws_vpc.unirep.id

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

data "aws_eip" "devops_eip" {
  id = "eipalloc-035f8ce4f49d02934"
}

resource "aws_subnet" "unirep_subnet_a" {
  vpc_id = aws_vpc.unirep.id
  cidr_block = "172.0.1.0/24"
  availability_zone = "${var.aws_region}a"
}

resource "aws_subnet" "unirep_subnet_b" {
  vpc_id = aws_vpc.unirep.id
  cidr_block = "172.0.2.0/24"
  availability_zone = "${var.aws_region}b"
}

resource "aws_db_subnet_group" "unirep_db_subnet" {
  name = "unirep-db-subnet"
  subnet_ids = [aws_subnet.unirep_subnet_a.id, aws_subnet.unirep_subnet_b.id]
}

resource "aws_db_instance" "unirep_rancher_db" {
  vpc_security_group_ids = [aws_security_group.unirep_sg.id]
  allocated_storage = 100
  db_name = "unirep"
  db_subnet_group_name = aws_db_subnet_group.unirep_db_subnet.name
  engine = "mysql"
  instance_class = "db.t3.medium"
  username = "admin"
  password = var.mysql_password
  skip_final_snapshot = true
  final_snapshot_identifier = "unirep-rancher-db-bak"
  identifier = "unirep-terraform"
  backup_retention_period = 7
  backup_window = "00:00-01:00"
  tags = {
    Name = "unirep-rancher-db"
    Creator = "terraform"
  }
}

resource "aws_eip_association" "devops_eip_assoc" {
  instance_id = aws_instance.unirep_rancher_server.id
  allocation_id = data.aws_eip.devops_eip.id
}

resource "aws_instance" "unirep_rancher_server" {
  ami = var.instance_ami

  vpc_security_group_ids = [aws_security_group.unirep_http_sg.id]

  instance_type = var.instance_type
  key_name = var.key_pair_name

  subnet_id = aws_subnet.unirep_subnet_a.id

  private_ip = "172.0.1.10"

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
    longhorn_version = var.longhorn_version
  })

  tags = {
    Name = "unirep-rancher-server"
    Creator = "terraform"
  }
}

resource "aws_instance" "unirep_rancher_node" {
  count = 3

  ami = var.instance_ami

  vpc_security_group_ids = [aws_security_group.unirep_http_sg.id]

  instance_type = var.instance_type
  key_name = var.key_pair_name

  associate_public_ip_address = true

  subnet_id = aws_subnet.unirep_subnet_b.id

  depends_on = [aws_instance.unirep_rancher_server]

  root_block_device {
    volume_size = 80
  }

  ebs_block_device {
    # should automatically be /dev/nvme1n1
    device_name = "/dev/sdz"
    volume_size = 50
    volume_type = "gp3"
    throughput = 125
    delete_on_termination = true
  }

  user_data = templatefile("./rancher-node-init.tftpl", {
    kubernetes_version = var.kubernetes_version
    develop_kubernetes_token = var.develop_kubernetes_token
    longhorn_block_device = var.longhorn_block_device
    server_ip = "172.0.1.10"
  })

  tags = {
    Name = "unirep-rancher-node-${count.index}"
    Creator = "terraform"
  }
}
