resource "aws_internet_gateway" "week10-igw" {
  vpc_id = aws_vpc.week10-vpc.id

  tags = {
    Name = "week10-igw"
  }
}
