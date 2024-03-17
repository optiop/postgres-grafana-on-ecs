variable "repository_name" {
  type        = string
  description = "The name of the repository containing the image."
}

variable "certificate_arn" {
  type        = string
  description = "The ARN of the certificate to be used HTTPS in load balancer."
  default     = "arn:aws:acm:eu-central-1:615677714887:certificate/23b18173-af28-42e7-a686-dd19e9956614"
}

variable "cluster_id" {
  type        = string
  description = "The ID of the cluster to which the container blongs."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to which the container should be deployed."
}

variable "vpc_private_subnets" {
  type        = list(string)
  description = "The private subnets to which the container should be deployed."
}

variable "vpc_public_subnets" {
  type        = list(string)
  description = "The public subnets to which the container should be deployed."
}

variable "security_group_id" {
  type        = string
  description = "The security group to which the container should be attached."
}

variable "namespace_id" {
  type        = string
  description = "The ID of the namespace to which the container should be attached."
}

variable "secret_manager_name" {
  type        = string
  description = "The name of the secret manager."
}