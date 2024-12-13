output "peering_connection_id" {
  value = aws_vpc_peering_connection.primary_to_dr.id
}
