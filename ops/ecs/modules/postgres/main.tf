data "aws_secretsmanager_secret" "configs" {
  name = var.secret_manager_name
}

data "aws_secretsmanager_secret_version" "configs" {
  secret_id = data.aws_secretsmanager_secret.configs.id
}

data "aws_ecr_repository" "repository" {
  name = var.repository_name
}

# Creating an ECS task definition
resource "aws_ecs_task_definition" "task" {
  family                   = "postgres"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.execution_role.arn

  container_definitions = jsonencode([
    {
      name : "postgres",
      image : data.aws_ecr_repository.repository.repository_url,
      container_name: "postgres",
      container_port: 5432,
      essential : true,
      cpu : 512,
      memory : 1024,
      portMappings : [
        {
          containerPort : 5432,
          hostPort      : 5432,
          protocol      : "tcp"
        }
      ],
      logConfiguration : {
        logDriver : "awslogs",
        options : {
          "awslogs-group" : aws_cloudwatch_log_group.log_group.name,
          "awslogs-region" : "eu-central-1",
          "awslogs-stream-prefix" : "ecs-backend"
        }
      },
      environment : [
        {
          "name" : "POSTGRES_DB",
          "value" : jsondecode(data.aws_secretsmanager_secret_version.configs.secret_string)["DATABASE_NAME"]
        },
        {
          "name" : "POSTGRES_USER",
          "value" : jsondecode(data.aws_secretsmanager_secret_version.configs.secret_string)["DATABASE_USERNAME"]
        },
        {
          "name" : "POSTGRES_PASSWORD",
          "value" : jsondecode(data.aws_secretsmanager_secret_version.configs.secret_string)["DATABASE_PASSWORD"]
        }
      ],
    },
  ])
}

resource "aws_service_discovery_service" "database" {
  name = "postgres"
  dns_config {
    namespace_id = var.namespace_id
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = var.repository_name
  retention_in_days = 14
}

# Creating an ECS service
resource "aws_ecs_service" "service" {
  name            = "postgres"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  launch_type     = "EC2"

  network_configuration {
    security_groups = [var.security_group_id]
    subnets         = var.vpc_public_subnets
  }

  service_registries {
    registry_arn   = aws_service_discovery_service.database.arn
    container_name = "postgres"
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}
