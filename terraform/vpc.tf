resource "aws_vpc" "default" {
  cidr_block                       = var.vpc_cidr
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = true

  tags = merge(
    tomap({
      "Name" = "times-saving-api-${var.environment}-vpc"
    }),
    local.common_tags
  )
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = merge(
    tomap({
      "Name" = "main"
    }),
    local.common_tags
  )
}

resource "aws_egress_only_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

resource "aws_vpc_peering_connection" "db_peer" {
  peer_owner_id = var.peer_owner_id
  vpc_id        = aws_vpc.default.id
  peer_vpc_id   = var.peer_vpc_id

  tags = merge(
    tomap({
      "Name"                  = "VPC Peering between ${var.accepter_environment} ACS Saving Service and ${var.requester_environment} TNL Saving Service",
      "Requester_environment" = "Times Saving API VPC ${var.requester_environment}",
      "Accepter_environment"  = "ACS Saving Service VPC ${var.accepter_environment}"
    }),
    local.common_tags
  )
}

/*
  Public Subnet
*/
resource "aws_subnet" "eu-west-1a-public" {
  vpc_id = aws_vpc.default.id

  cidr_block        = var.public_subnet_cidr_1
  availability_zone = "eu-west-1a"

  tags = merge(
    tomap({
      "Name" = "times-saving-api-${var.environment}-public-subnet-1a",
    }),
    local.common_tags
  )
}

resource "aws_subnet" "eu-west-1b-public" {
  vpc_id = aws_vpc.default.id

  cidr_block        = var.public_subnet_cidr_2
  availability_zone = "eu-west-1b"

  tags = merge(
    tomap({
      "Name" = "times-saving-api-${var.environment}-public-subnet-1b",
    }),
    local.common_tags
  )
}

resource "aws_subnet" "eu-west-1c-public" {
  vpc_id = aws_vpc.default.id

  cidr_block        = var.public_subnet_cidr_3
  availability_zone = "eu-west-1c"

  tags = merge(
    tomap({
      "Name" = "times-saving-api-${var.environment}-public-subnet-1c",
    }),
    local.common_tags
  )
}

resource "aws_route_table" "eu-west-1-public" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.default.id
  }

  tags = merge(
    tomap({
      "Name" = "times-saving-api-${var.environment}-public-subnets",
    }),
    local.common_tags
  )
}

resource "aws_route_table_association" "eu-west-1-public-a" {
  subnet_id      = aws_subnet.eu-west-1a-public.id
  route_table_id = aws_route_table.eu-west-1-public.id
}

resource "aws_route_table_association" "eu-west-1-public-b" {
  subnet_id      = aws_subnet.eu-west-1b-public.id
  route_table_id = aws_route_table.eu-west-1-public.id
}

resource "aws_route_table_association" "eu-west-1-public-c" {
  subnet_id      = aws_subnet.eu-west-1c-public.id
  route_table_id = aws_route_table.eu-west-1-public.id
}

resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.default]

  tags = merge(
    tomap({
      "Name" = "times-saving-api-${var.environment}-nat-eip",
    }),
    local.common_tags
  )
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.eu-west-1a-public.id

  tags = merge(
    tomap({
      "Name" = "times-saving-api-${var.environment}-nat-gw",
    }),
    local.common_tags
  )

  depends_on = [aws_eip.nat_eip, aws_subnet.eu-west-1a-public]
}

/*
  Private Subnet
*/
resource "aws_subnet" "eu-west-1a-private" {
  vpc_id = aws_vpc.default.id

  cidr_block        = var.private_subnet_cidr_1
  availability_zone = "eu-west-1a"

  tags = merge(
    tomap({
      "Name" = "times-saving-api-${var.environment}-private-subnet-1a",
    }),
    local.common_tags
  )
}

resource "aws_subnet" "eu-west-1b-private" {
  vpc_id = aws_vpc.default.id

  cidr_block        = var.private_subnet_cidr_2
  availability_zone = "eu-west-1b"

  tags = merge(
    tomap({
      "Name" = "times-saving-api-${var.environment}-private-subnet-1b",
    }),
    local.common_tags
  )
}

resource "aws_subnet" "eu-west-1c-private" {
  vpc_id = aws_vpc.default.id

  cidr_block        = var.private_subnet_cidr_3
  availability_zone = "eu-west-1c"

  tags = merge(
    tomap({
      "Name" = "times-saving-api-${var.environment}-private-subnet-1c",
    }),
    local.common_tags
  )
}

resource "aws_route_table" "eu-west-1-private" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.default.id
  }

  route {
    cidr_block                = var.peer_cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.db_peer.id
  }

  route {
    cidr_block         = var.eks_cidr_block
    transit_gateway_id = var.transit_gateway_id
  }

  tags = merge(
    tomap({
      "Name" = "times-saving-api-${var.environment}-private-subnets",
    }),
    local.common_tags
  )
}

resource "aws_route_table_association" "eu-west-1-private-a" {
  subnet_id      = aws_subnet.eu-west-1a-private.id
  route_table_id = aws_route_table.eu-west-1-private.id
}

resource "aws_route_table_association" "eu-west-1-private-b" {
  subnet_id      = aws_subnet.eu-west-1b-private.id
  route_table_id = aws_route_table.eu-west-1-private.id
}

resource "aws_route_table_association" "eu-west-1-private-c" {
  subnet_id      = aws_subnet.eu-west-1c-private.id
  route_table_id = aws_route_table.eu-west-1-private.id
}

/*
  Default security group
*/
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.default.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [var.eks_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = ["::/0"]
  }
}

/*
  Outputs
*/
output "public_api_vpc_id" {
  value = aws_vpc.default.id
}

output "public_subnet_id_1a" {
  value = aws_subnet.eu-west-1a-public.id
}

output "public_subnet_id_1b" {
  value = aws_subnet.eu-west-1b-public.id
}

output "public_subnet_id_1c" {
  value = aws_subnet.eu-west-1c-public.id
}

output "private_subnet_id_1a" {
  value = aws_subnet.eu-west-1a-private.id
}

output "private_subnet_id_1b" {
  value = aws_subnet.eu-west-1b-private.id
}

output "private_subnet_id_1c" {
  value = aws_subnet.eu-west-1c-private.id
}

output "security_group_default" {
  value = aws_default_security_group.default.id
}

output "eip_nat_allocation_id" {
  value = aws_eip.nat_eip.id
}

output "peer_account_id" {
  value = var.peer_owner_id
}

output "peer_cidr_block" {
  value = var.peer_cidr_block
}

output "peer_vpc_id" {
  value = var.peer_vpc_id
}

# Transit Gateway

resource "aws_ec2_transit_gateway_vpc_attachment" "tsa" {
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = aws_vpc.default.id
  subnet_ids = [
    aws_subnet.eu-west-1a-private.id,
    aws_subnet.eu-west-1b-private.id,
    aws_subnet.eu-west-1c-private.id
  ]
  tags = local.common_tags
}

resource "aws_route" "eks_tgw_vpc_route" {
  destination_cidr_block = var.eks_cidr_block
  route_table_id         = aws_route_table.eu-west-1-private.id
  transit_gateway_id     = var.transit_gateway_id
}
