# Provider configuration variables
variable "aws_region" {
  description = "AWS region to use"
  type        = string
  default     = "eu-central-1"
}

# VPC configuration variables
variable "vpc_cidr" {
  description = "CIDR block for main VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Secret Manager Name
variable "secret_manager_name" {
  description = "Name of the secret manager"
  type        = string
  default     = "grafana-postgres-on-ecs"
}
