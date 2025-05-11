resource "aws_vpc" "eks" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.eks.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_subnet" "eks" {
  count                   = 2
  vpc_id                  = aws_vpc.eks.id
  cidr_block              = cidrsubnet(aws_vpc.eks.cidr_block, 8, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.eks[count.index].id
  route_table_id = aws_route_table.public.id
}
