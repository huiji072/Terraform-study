resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "metaverse2-stage-vpc"
  }

  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public" {
  count = 3

  cidr_block = "10.0.${count.index + 1}.0/24"
  vpc_id     = aws_vpc.this.id
  map_public_ip_on_launch = true  # 인스턴스가 시작될 때 자동으로 퍼블릭 IP를 할당

  tags = {
    Name = "metaverse2-stage-public-subnet-${count.index+1}"
  }

  availability_zone = element(data.aws_availability_zones.available.names, count.index)
}

resource "aws_subnet" "private" {
  count = 6

  cidr_block = "10.0.${count.index + 101}.0/24"
  vpc_id     = aws_vpc.this.id
  map_public_ip_on_launch = true  # 인스턴스가 시작될 때 자동으로 퍼블릭 IP를 할당

  tags = {
    Name = "metaverse2-stage-private-subnet-${count.index+1}"
  }

  availability_zone = element(data.aws_availability_zones.available.names, count.index % 3)
}

resource "aws_eip" "nat" {
  count = 3

  tags = {
    Name = "metaverse2-stage-nat-eip-${count.index}"
  }
}

resource "aws_nat_gateway" "this" {
  count = 3

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "metaverse2-stage-nat-gateway-${count.index+1}"
  }
}

resource "aws_route_table" "private" {
  count = length(aws_subnet.private)

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "metaverse2-stage-private-route-table-${count.index+1}"
  }
}

resource "aws_route" "private-nat" {
  count = length(aws_subnet.private)

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index % 3].id
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "metaverse2-stage-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "metaverse2-stage-public-route-table"
  }
}

resource "aws_route" "public-igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

data "aws_availability_zones" "available" {}
