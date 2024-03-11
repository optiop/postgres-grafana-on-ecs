module "vpc" {
  source = "./modules/vpc"
  name   = "ecs-vpc"
}

module "cluster" {
  source                = "./modules/cluster"
  name                  = "ecs-cluster"
  vpc_security_group_id = module.vpc.security_group_id
  vpc_public_subnets    = module.vpc.public_subnets

  depends_on = [module.vpc]
}

module "grafana" {
  source              = "./modules/grafana"
  repository_name     = "postgres-grafana-on-ecs-grafana-repo"
  cluster_id          = module.cluster.cluster_id
  vpc_id              = module.vpc.vpc_id
  vpc_public_subnets  = module.vpc.public_subnets
  security_group_id   = module.vpc.security_group_id
  namespace_id        = module.vpc.namespace_id
  secret_manager_name = var.secret_manager_name

  depends_on = [module.cluster]
}

module "postgres" {
  source              = "./modules/postgres"
  repository_name     = "postgres-grafana-on-ecs-postgres-repo"
  cluster_id          = module.cluster.cluster_id
  vpc_id              = module.vpc.vpc_id
  vpc_public_subnets  = module.vpc.public_subnets
  security_group_id   = module.vpc.security_group_id
  namespace_id        = module.vpc.namespace_id
  secret_manager_name = var.secret_manager_name

  depends_on = [module.cluster]
}