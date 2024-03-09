# Creating an ECS cluster
resource "aws_ecs_cluster" "cluster" {
  name = var.name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_launch_configuration" "ecs_cfg" {
  name          = "ecs-instance"
  image_id      = "ami-06581a55723db5feb"
  instance_type = "t2.small"

  iam_instance_profile = aws_iam_instance_profile.ecsInstanceRole.name

  associate_public_ip_address = true
  security_groups             = [var.vpc_security_group_id]

  user_data = <<EOF
  #!/bin/bash
  echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCt/+JcQz8a8UwAYaWUqGIHMWtHOkLKuzbCIy3aQwDMwxRMpEfUXThoiqOnszx8ntWEVEYpgQXJzoi2ltkL5odO1nzWxxLGUeTb3dNa8eaABvhKrrXvB7yZ/W9K2ZQ/tS5JA62zxQg+a1aFw5eT8GtiRm3Fjivo5K5PKOHQsYyYQwsu0E17K/u000+Gef9l1ZKaf/LWujISx8mpXEABFKr1IJRxTI0PeQidLHJSwoiKZ81tCfcRBi1yEJWssfgmdeZZlZvqeKKtd1Z4CXV8ez7BYFCsD3qzutUHUi2cQPTTQPJ084DN/6yPhIOuBevfXHbWxVexb6AorY/0ndPvomVIz9Oc/1B1UY1VvrtQdHwldQ3Wj4BfeHudrrsYdvDa6IgEgVYZM0ciZOGakk2/MXWUpysNtDy89TlNuIEPuZGblJ/LLIxRlF+v89is3/F16btQMz1FYwQePvpEJiMY68ZCqRf8o93D38iP0zRU8OEbfvR3fAAe3UdDXULjyFWOKMEX/yVlKwaXf+XJ6c+z/UKu8+4NtZJdU4nMmqLNc+YFsykNaPU9Grl/1lAIgP6mWZuZxqve0Ht+CqOtxnka8uwmK0DPxBJX9V+Mtj7ATgJtXnopPKvFa6ldpWmbOVU/KjiCQgNyJ6V7Z2kcQtyIBIbChU3ktts0gyquEZlFu1iJqQ== mehrshadlotfi@Mehrshads-MBP.fritz.box' >> /home/ec2-user/.ssh/authorized_keys
  echo ECS_CLUSTER=${var.name} >> /etc/ecs/ecs.config
  EOF
}

resource "aws_autoscaling_group" "ecs_instance_asg" {
  launch_configuration = aws_launch_configuration.ecs_cfg.name

  vpc_zone_identifier = var.vpc_public_subnets
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1

  tag {
    key                 = "AmazonECSManaged"
    value               = "ecs-instance"
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = "default"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_instance_asg.arn
    managed_scaling {
      status          = "ENABLED"
      target_capacity = 1
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster_capacity_providers" {
  cluster_name       = aws_ecs_cluster.cluster.name
  capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
  }
}
