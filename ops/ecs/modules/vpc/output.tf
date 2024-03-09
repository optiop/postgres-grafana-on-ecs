output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "security_group_id" {
  value = aws_security_group.sg.id
}

output "namespace_id" {
  value = aws_service_discovery_private_dns_namespace.namespace.id
}