variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "domain_name" {
  type        = string
  description = "Domain name for External DNS"
  default     = "knowledgecity.com"
}

variable "environment" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type    = list(string)
  default = []
}



variable "dr_region" {
  type        = string
  description = "AWS region"
}
