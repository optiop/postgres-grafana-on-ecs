# Elastic Container Service (ECS) Stack

## Usage

1. Create a secret name `grafana-postgres-on-ecs` in AWS Secret Manager with the following secrets.

| Key | Value |
| --- | --- |
| `DATABASE_USERNAME` | Username for database (e.g. postgres) |
| `DATABASE_PASSWORD` | Password for database (e.g. passw0rd) |
| `DATABASE_HOST` | `postgres.service.local` |
| `DATABASE_NAME` | Name of the database (e.g. postgres) |

2. We need to have two ECR repositories `grafana` and `postgres`. Set the variable 
`repository_name` in `modules/grafana/variables.tf` and `modules/postgres/variables.tf`. 
The subdirectory `repo/ops/repository` contains the 
terraform code to create the ECR repositories, and the subdirectory `repo/src/`
contains the Dockerfile and the code for the services.


3. Add your public key to `main.tf` to allow ssh access to the EC2 instances.


## References 
* [Amazon Elastic Container Service (ECS)](https://aws.amazon.com/ecs/)
