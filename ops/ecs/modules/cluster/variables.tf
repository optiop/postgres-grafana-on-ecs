variable "name" {
  type        = string
  description = "The name of the cluster"
}

variable "instance_type" {
  type        = string
  description = "The instance type for the ECS instances"
  default     = "t2.small"
}

variable "vpc_security_group_id" {
  type        = string
  description = "The security group id for the ECS instances"
}

variable "vpc_public_subnets" {
  type        = list(string)
  description = "The public subnets for the ECS instances"
}

variable "vpc_private_subnets" {
  type        = list(string)
  description = "The private subnets for the ECS instances"
}