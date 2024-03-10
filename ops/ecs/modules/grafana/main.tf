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
  family                   = "grafana"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = 512
  memory                   = 512
  execution_role_arn       = aws_iam_role.execution_role.arn

  container_definitions = jsonencode([
    {
      name : "grafana",
      image : data.aws_ecr_repository.repository.repository_url,
      container_name: "grafana",
      essential : true,
      cpu : 512,
      memory : 512,
      environment : [
        {
          "name" : "POSTGRES_USER",
          "value" : jsondecode(data.aws_secretsmanager_secret_version.configs.secret_string)["DATABASE_USERNAME"]
        },
        {
          "name" : "POSTGRES_PASSWORD",
          "value" : jsondecode(data.aws_secretsmanager_secret_version.configs.secret_string)["DATABASE_PASSWORD"]
        },
        {
          "name" : "POSTGRES_HOST",
          "value" : jsondecode(data.aws_secretsmanager_secret_version.configs.secret_string)["DATABASE_HOST"]
        },
        {
          "name" : "POSTGRES_DB",
          "value" : jsondecode(data.aws_secretsmanager_secret_version.configs.secret_string)["DATABASE_NAME"]
        },
        {
          "name" : "POSTGRES_PORT",
          "value" : "5432"
        }
      ]
      logConfiguration : {
        logDriver : "awslogs",
        options : {
          "awslogs-group" : aws_cloudwatch_log_group.log_group.name,
          "awslogs-region" : "eu-central-1",
          "awslogs-stream-prefix" : var.repository_name
        }
      },
      portMappings : [
        {
          containerPort : 3000,
          hostPort : 3000,
        },
      ],
    },
  ])
}

resource "aws_service_discovery_service" "grafana" {
  name = "grafana"
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
  name            = "grafana"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  launch_type     = "EC2"

  network_configuration {
    security_groups = [var.security_group_id]
    subnets         = var.vpc_public_subnets
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "grafana"
    container_port   = 3000
  }

  service_registries {
    registry_arn   = aws_service_discovery_service.grafana.arn
    container_name = "grafana"
  }

  lifecycle {
    ignore_changes = [task_definition]
  }

  depends_on = [aws_lb_target_group.target_group]
}

resource "aws_lb" "load_balancer" {
  name               = "grafana-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.vpc_public_subnets

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = "alb-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/api/health"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
  }
}
