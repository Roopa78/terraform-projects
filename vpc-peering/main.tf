resource "aws_s3_bucket" "tf_state" {
  bucket = "my-terraform-state-bucket-roopaks"
}
resource "aws_vpc" "primary_vpc" {
  cidr_block       = var.primary_vpc_cidr
  provider = aws.primary
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "primary-vpc-${var.primary}"
  }
}
resource "aws_vpc" "secondary_vpc" {
  cidr_block       = var.secondary_vpc_cidr
  provider = aws.secondary
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "secondary-vpc-${var.secondary}"
  }
}
resource "aws_vpc" "third_vpc" {
  cidr_block       = var.third_vpc_cidr
  provider = aws.third
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "third-vpc-${var.third}"
  }
}
resource "aws_subnet" "primary_subnet" {
  provider = aws.primary
  vpc_id     = aws_vpc.primary_vpc.id
  cidr_block = var.primary_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.primary.names[0]
  

  tags = {
    Name = "primary-subnet-${var.primary}"
  }
}
resource "aws_subnet" "secondary_subnet" {
  provider = aws.secondary
  vpc_id     = aws_vpc.secondary_vpc.id
  cidr_block = var.secondary_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.secondary.names[1]
  

  tags = {
    Name = "secondary-subnet-${var.secondary}"
  }
}
resource "aws_subnet" "third_subnet" {
  provider = aws.third
  vpc_id     = aws_vpc.third_vpc.id
  cidr_block = var.third_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.third.names[0]
  

  tags = {
    Name = "third-subnet-${var.third}"
  }
}

resource "aws_internet_gateway" "primary_igw" {
  provider = aws.primary
  vpc_id = aws_vpc.primary_vpc.id

  tags = {
    Name = "primary-igw-${var.primary}"
  }
}
resource "aws_internet_gateway" "secondary_igw" {
 provider = aws.secondary
 vpc_id = aws_vpc.secondary_vpc.id

 tags = {
    Name = "secondary-igw-${var.secondary}"
  }
}
resource "aws_internet_gateway" "third_igw" {
  provider = aws.third
  vpc_id = aws_vpc.third_vpc.id

  tags = {
    Name = "third-igw-${var.third}"
  }
}
resource "aws_route_table" "primary_route_table" {
  vpc_id = aws_vpc.primary_vpc.id
  provider = aws.primary

  tags = {
    Name = "primary-route-table-${var.primary}"
  }
}
resource "aws_route_table" "secondary_route_table" {
  vpc_id = aws_vpc.secondary_vpc.id
  provider = aws.secondary

  tags = {
    Name = "secondary-route-table-${var.secondary}"
  }
}
resource "aws_route_table" "third_route_table" {
  vpc_id = aws_vpc.third_vpc.id
  provider = aws.third

  tags = {
    Name = "third-route-table-${var.third}"
  }
}
resource "aws_route_table_association" "primary-rta" {
  route_table_id = aws_route_table.primary_route_table.id
  subnet_id = aws_subnet.primary_subnet.id
  provider = aws.primary
}
resource "aws_route_table_association" "secondary-rta" {
  route_table_id = aws_route_table.secondary_route_table.id
  subnet_id = aws_subnet.secondary_subnet.id
  provider = aws.secondary
}
resource "aws_route_table_association" "third-rta" {
  route_table_id = aws_route_table.third_route_table.id
  subnet_id = aws_subnet.third_subnet.id
  provider = aws.third
}
resource "aws_vpc_peering_connection" "primary-to-secondary" {
  provider = aws.primary
  peer_vpc_id   = aws_vpc.secondary_vpc.id
  vpc_id        = aws_vpc.primary_vpc.id
  peer_region   = var.secondary
  auto_accept = false
  tags  = {
    Name = "primary-to-secondary-peering"
    environment = "demo"
    side = "requestor"
  }
}
resource "aws_vpc_peering_connection_accepter" "secondary-accepter" {
  provider = aws.secondary
  vpc_peering_connection_id = aws_vpc_peering_connection.primary-to-secondary.id
  auto_accept = true
  tags  = {
    Name = "secondary-peering-acceptor"
    environment = "demo"
    side = "acceptor"
  }
}
resource "aws_vpc_peering_connection" "secondary-to-third" {
  provider = aws.secondary
  peer_vpc_id   = aws_vpc.third_vpc.id
  vpc_id        = aws_vpc.secondary_vpc.id
  peer_region   = var.third
  auto_accept = false
  tags  = {
    Name = "secondary-to-third-peering"
    environment = "demo"
    side = "requestor"
  }
}
resource "aws_vpc_peering_connection_accepter" "third-accepter" {
  provider = aws.third
  vpc_peering_connection_id = aws_vpc_peering_connection.secondary-to-third.id
  auto_accept = true
  tags  = {
    Name = "third-peering-acceptor"
    environment = "demo"
    side = "acceptor"
  }
}
resource "aws_route" "primary-to-secondary" {
  route_table_id            = aws_route_table.primary_route_table.id
  destination_cidr_block    = var.secondary_vpc_cidr
  provider = aws.primary
  vpc_peering_connection_id = aws_vpc_peering_connection.primary-to-secondary.id

  depends_on = [aws_vpc_peering_connection_accepter.secondary-accepter]
}
resource "aws_route" "secondary-to-primary" {
  route_table_id            = aws_route_table.secondary_route_table.id
  destination_cidr_block    = var.primary_vpc_cidr
  provider = aws.secondary
  vpc_peering_connection_id = aws_vpc_peering_connection.primary-to-secondary.id

  depends_on = [aws_vpc_peering_connection_accepter.secondary-accepter]
}
resource "aws_route" "secondary-to-third" {
  route_table_id            = aws_route_table.secondary_route_table.id
  destination_cidr_block    = var.third_vpc_cidr
  provider = aws.secondary
  vpc_peering_connection_id = aws_vpc_peering_connection.secondary-to-third.id

  depends_on = [aws_vpc_peering_connection_accepter.third-accepter]
}
resource "aws_route" "third-to-secondary" {
  route_table_id            = aws_route_table.third_route_table.id
  destination_cidr_block    = var.secondary_vpc_cidr
  provider = aws.third
  vpc_peering_connection_id = aws_vpc_peering_connection.secondary-to-third.id

  depends_on = [aws_vpc_peering_connection_accepter.third-accepter]
}
resource "aws_route" "vpc1_to_vpc3" {
  provider               = aws.primary
  route_table_id         = aws_route_table.primary_route_table.id
  destination_cidr_block = var.third_vpc_cidr

  transit_gateway_id = aws_ec2_transit_gateway.vpc1-vpc3-tgw-primary.id
}
resource "aws_route" "vpc3_to_vpc1" {
  provider               = aws.third
  route_table_id         = aws_route_table.third_route_table.id
  destination_cidr_block = var.primary_vpc_cidr

  transit_gateway_id = aws_ec2_transit_gateway.vpc1-vpc3-tgw-primary.id
}
resource "aws_ec2_transit_gateway" "vpc1-vpc3-tgw-primary" {
  description = "connecting vpc1 and vpc3"
  provider = aws.primary

  tags = {
    Name = "main-tgw-${var.primary}"
}
}
resource "aws_ec2_transit_gateway_vpc_attachment" "primary_attachment" {
  provider = aws.primary

  transit_gateway_id = aws_ec2_transit_gateway.vpc1-vpc3-tgw-primary.id
  vpc_id             = aws_vpc.primary_vpc.id
  subnet_ids         = [aws_subnet.primary_subnet.id]
}
resource "aws_ec2_transit_gateway_vpc_attachment" "third_attachment" {
  provider = aws.third

  transit_gateway_id = aws_ec2_transit_gateway.vpc1-vpc3-tgw-primary.id
  vpc_id             = aws_vpc.third_vpc.id
  subnet_ids         = [aws_subnet.third_subnet.id]
}
resource "aws_ec2_transit_gateway_route_table" "tgw_route_table" {
  provider = aws.primary
  transit_gateway_id = aws_ec2_transit_gateway.vpc1-vpc3-tgw-primary.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "primary_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.primary_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "third_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.third_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table.id
}
resource "aws_security_group" "primary_sg" {
  provider    = aws.primary
  name        = "primary-vpc-sg"
  description = "Security group for Primary VPC instance"
  vpc_id      = aws_vpc.primary_vpc.id


  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP from Secondary VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.secondary_vpc_cidr ,
    var.third_vpc_cidr]
  }

  ingress {
    description = "All traffic from Secondary VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.secondary_vpc_cidr,
     var.third_vpc_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Primary-VPC-SG"
    Environment = "Demo"
  }
}

# Security Group for Secondary VPC EC2 instance
resource "aws_security_group" "secondary_sg" {
  provider    = aws.secondary
  name        = "secondary-vpc-sg"
  description = "Security group for Secondary VPC instance"
  vpc_id      = aws_vpc.secondary_vpc.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP from Primary VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.primary_vpc_cidr,
     var.third_vpc_cidr]
  }

  ingress {
    description = "All traffic from Primary VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.primary_vpc_cidr,
     var.third_vpc_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Secondary-VPC-SG"
    Environment = "Demo"
  }
}
resource "aws_security_group" "third_sg" {
  provider    = aws.third
  name        = "third-vpc-sg"
  description = "Security group for Third VPC instance"
  vpc_id      = aws_vpc.third_vpc.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP from secondary VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.secondary_vpc_cidr,
     var.primary_vpc_cidr]
  }

  ingress {
    description = "All traffic from secondary VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.secondary_vpc_cidr,
    var.primary_vpc_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Third-VPC-SG"
    Environment = "Demo"
  }
}
resource "aws_instance" "primary_instance" {
  provider               = aws.primary
  ami                    = data.aws_ami.ami-primary.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.primary_subnet.id
  vpc_security_group_ids = [aws_security_group.primary_sg.id]
  key_name               = var.primary_key_name

  user_data = local.primary_user_data

  tags = {
    Name        = "Primary-VPC-Instance"
    Environment = "Demo"
    Region      = var.primary
  }

  depends_on = [aws_vpc_peering_connection_accepter.secondary-accepter]
}

# EC2 Instance in Secondary VPC
resource "aws_instance" "secondary_instance" {
  provider               = aws.secondary
  ami                    = data.aws_ami.ami-secondary.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.secondary_subnet.id
  vpc_security_group_ids = [aws_security_group.secondary_sg.id]
  key_name               = var.secondary_key_name

  user_data = local.secondary_user_data

  tags = {
    Name        = "Secondary-VPC-Instance"
    Environment = "Demo"
    Region      = var.secondary
  }

  depends_on = [aws_vpc_peering_connection_accepter.secondary-accepter]
}
resource "aws_instance" "third_instance" {
  provider               = aws.third
  ami                    = data.aws_ami.ami-third.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.third_subnet.id
  vpc_security_group_ids = [aws_security_group.third_sg.id]
  key_name               = var.third_key_name

  user_data = local.third_user_data

  tags = {
    Name        = "Third-VPC-Instance"
    Environment = "Demo"
    Region      = var.third
  }

  depends_on = [aws_vpc_peering_connection_accepter.third-accepter ,
  aws_ec2_transit_gateway_vpc_attachment.primary_attachment]
}
