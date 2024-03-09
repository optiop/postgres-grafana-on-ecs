variable "name" {
  type        = string
  description = "The name of the cluster"
}

variable "vpc_security_group_id" {
  type        = string
  description = "The security group id for the ECS instances"
}

variable "vpc_public_subnets" {
  type        = list(string)
  description = "The public subnets for the ECS instances"
}