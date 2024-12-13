# DR VPC Peering
resource "aws_vpc_peering_connection" "primary_to_dr" {
  provider = aws.primary

  vpc_id      = var.primary_vpc_id
  peer_vpc_id = var.dr_vpc_id
  peer_region = var.dr_region
  auto_accept = false

  tags = merge(var.tags, {
    Name = "${var.environment}-primary-to-dr"
  })
}

resource "aws_vpc_peering_connection_accepter" "dr" {
  provider = aws.dr

  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_dr.id
  auto_accept               = true

  tags = merge(var.tags, {
    Name = "${var.environment}-dr-accepter"
  })
}

# Route Tables
resource "aws_route" "primary_to_dr" {
  provider = aws.primary
  count    = length(var.primary_route_table_ids)

  route_table_id            = var.primary_route_table_ids[count.index]
  destination_cidr_block    = var.dr_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_dr.id
}

resource "aws_route" "dr_to_primary" {
  provider = aws.dr
  count    = length(var.dr_route_table_ids)

  route_table_id            = var.dr_route_table_ids[count.index]
  destination_cidr_block    = var.primary_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_dr.id
}
