resource "aws_vpc" "tf_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "tf_vpc"
  }
}

resource "aws_subnet" "tf_public_subnet" {
  vpc_id                  = aws_vpc.tf_vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "tf-public-subnet"
  }
}

resource "aws_internet_gateway" "tf_igw" {
  vpc_id = aws_vpc.tf_vpc.id

  tags = {
    Name = "tf_igw"
  }
}

resource "aws_route_table" "tf_public_rt" {
  vpc_id = aws_vpc.tf_vpc.id

  tags = {
    Name = "tf_public_rt"
  }
}

resource "aws_route" "tf_default_route" {
  route_table_id         = aws_route_table.tf_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.tf_igw.id
}

resource "aws_route_table_association" "tf_public_assoc" {
  subnet_id      = aws_subnet.tf_public_subnet.id
  route_table_id = aws_route_table.tf_public_rt.id
}

resource "aws_security_group" "tf_sg" {
  name        = "tf_sg"
  description = "dev security group"
  vpc_id      = aws_vpc.tf_vpc.id

  tags = {
    Name = "tf_sg"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
 from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]


  }
}

resource "aws_key_pair" "tf_auth" {
  key_name   = "tf_key"
  public_key = "specify-the-public-key-or-path-to-the-public-key"
}

resource "aws_instance" "dev_node" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.tf_auth.id
  vpc_security_group_ids = [aws_security_group.tf_sg.id]
  subnet_id              = aws_subnet.tf_public_subnet.id
  user_data = file("userdata.tpl")

  root_block_device {
    volume_size = 8


    tags = {
      Name = "dev_node"
    }
  }

  provisioner "local-exec"{
    command = templatefile("mac-ssh-config.tpl" , {
      hostname = self.public_ip,
      user = "ubuntu",
      identity_file= "specify-path-to-login-key-file"
    })
    interpreter = ["bash", "-c"]
  }

}