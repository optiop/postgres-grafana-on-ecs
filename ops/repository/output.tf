output "aws_iam_role" {
  value = aws_iam_role.github_action_role.arn
}

output "aws_ecr_db_repo" {
  value = aws_ecr_repository.postgres.repository_url
}

output "aws_ecr_backend_repo" {
  value = aws_ecr_repository.grafana.repository_url
}