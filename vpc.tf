### ingresar credenciales
variable "access_key" {}
variable "secret_key" {}
variable "region" {}
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

#-----------------------------------------------------------
#VPC con 3 capas de subnets
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16" # que le permite contar con 65.536 IPs privadas.
  enable_dns_hostnames = true
  enable_dns_support = true

  tags {
     Name = "main"
     env = "terraform"
  }
}
#-----------------------------------------------------------
#.......................
###Subnets Públicas### salida y entrada desde internet.
#.......................

#Public Subnet 0
resource "aws_subnet" "public-subnet-0" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "us-west-2a"
  cidr_block        = "10.0.128.0/20"
  map_public_ip_on_launch = true
  tags = {
    Name      = "public-subnet-0"
    env       = "terraform"
    layer     = "public"
  }
}

#Public Subnet 1
resource "aws_subnet" "public-subnet-1" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "us-west-2b"
  cidr_block        = "10.0.144.0/20"
  map_public_ip_on_launch = true
  tags = {
    Name      = "public-subnet-1"
    env       = "terraform"
    layer     = "public"
  }
}

#Public Subnet 2
resource "aws_subnet" "public-subnet-2" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "us-west-2c"
  cidr_block        = "10.0.160.0/20"	
  map_public_ip_on_launch = true
  tags = {
    Name      = "public-subnet-2"
    env       = "terraform"
    layer     = "public"
  }
}

#------------------------------------------------------------
###############################
## Internet_gateway and route table
###############################

resource "aws_internet_gateway" "main-igw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name      = "main-igw"
    env       = "terraform"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main-igw.id}" 
  }

  tags = {
    Name      = "public-rt"
    env       = "terraform"
  }
}

resource "aws_route_table_association" "public-subnets-assoc-0" {
  subnet_id      = "${element(aws_subnet.public-subnet-0.*.id, count.index)}"
  route_table_id = "${aws_route_table.public-rt.id}"
}
resource "aws_route_table_association" "public-subnets-assoc-1" {
  subnet_id      = "${element(aws_subnet.public-subnet-1.*.id, count.index)}"
  route_table_id = "${aws_route_table.public-rt.id}"
}
resource "aws_route_table_association" "public-subnets-assoc-2" {
  subnet_id      = "${element(aws_subnet.public-subnet-2.*.id, count.index)}"
  route_table_id = "${aws_route_table.public-rt.id}"
}


#--------------------------------------------------------------
#..................
#Private Subnets A = con salida a internet sin acceso desde internet.
#..................
 
#Public Subnet A0
resource "aws_subnet" "private-subnet-A0" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "us-west-2a"
  cidr_block        = "10.0.0.0/19"
  map_public_ip_on_launch = false
  tags = {
    Name      = "private-subnet-A0"
    env       = "terraform"
    layer     = "private"
  }
}

#Public Subnet A1
resource "aws_subnet" "private-subnet-A1" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "us-west-2b"
  cidr_block        = "10.0.32.0/19"
  map_public_ip_on_launch = false
  tags = {
    Name      = "private-subnet-A1"
    env       = "terraform"
    layer     = "private"
  }
}

#Public Subnet A2
resource "aws_subnet" "private-subnet-A2" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "us-west-2c"
  cidr_block        = "10.0.64.0/19"
  map_public_ip_on_launch = false
  tags = {
    Name      = "private-subnet-A2"
    env       = "terraform"
    layer     = "private"
  }
}
#--------------------------------------------------------------
###########################
# NAT Gateway and route table
###########################

resource "aws_eip" "natgw-a" {
  vpc = true
}

resource "aws_nat_gateway" "natgw-a" {
  allocation_id = "${aws_eip.natgw-a.id}"
  subnet_id     = "${aws_subnet.public-subnet-0.id}"
}

resource "aws_route_table" "private-rt" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.natgw-a.id}"
  }

  tags = {
    Name      = "private-rt"
    env       = "terraform"
  }
}

resource "aws_route_table_association" "private-subnets-assoc-0" {
  subnet_id      = "${element(aws_subnet.private-subnet-A0.*.id, count.index)}"
  route_table_id = "${aws_route_table.private-rt.id}"
}

resource "aws_route_table_association" "private-subnets-assoc-1" {
  subnet_id      = "${element(aws_subnet.private-subnet-A1.*.id, count.index)}"
  route_table_id = "${aws_route_table.private-rt.id}"
}
resource "aws_route_table_association" "private-subnets-assoc-2" {
  subnet_id      = "${element(aws_subnet.private-subnet-A2.*.id, count.index)}"
  route_table_id = "${aws_route_table.private-rt.id}"
}

#---------------------------------------------------------
#..................
#Private Subnets B = sin salida ni entrada (internet)
#..................

#Private Subnet B0
resource "aws_subnet" "private-subnet-B0" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "us-west-2a"
  cidr_block        = "10.0.192.0/21"
  map_public_ip_on_launch = false
  tags = {
    Name      = "private-subnet-B0"
    env       = "terraform"
    layer     = "private"
  }
}

#Private Subnet B1
resource "aws_subnet" "private-subnet-B1" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "us-west-2b"
  cidr_block        = "10.0.200.0/21"
  map_public_ip_on_launch = false
  tags = {
    Name      = "private-subnet-B1"
    env       = "terraform"
    layer     = "private"
  }
}

#Private Subnet B2
resource "aws_subnet" "private-subnet-B2" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "us-west-2c"
  cidr_block        = "10.0.208.0/21"
  map_public_ip_on_launch = false
  tags = {
    Name      = "private-subnet-B2"
    env       = "terraform"
    layer     = "private"
  }
}

#-----------------------------------------------------------
output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "public-subnet-0" {
  value = "${aws_subnet.public-subnet-0.id}"
}
output "private-subnet-A0" {
  value = "${aws_subnet.private-subnet-A0.id}"
}
output "private-subnet-B0" {
  value = "${aws_subnet.private-subnet-B0.id}"
}

