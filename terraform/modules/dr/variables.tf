variable "environment" {
  type = string
}

variable "primary_vpc_id" {
  type = string
}

variable "dr_vpc_id" {
  type = string
}

variable "primary_vpc_cidr" {
  type = string
}

variable "dr_vpc_cidr" {
  type = string
}

variable "primary_route_table_ids" {
  type = list(string)
}

variable "dr_route_table_ids" {
  type = list(string)
}

variable "dr_region" {
  type = string
}

variable "tags" {
  type = map(string)
}
