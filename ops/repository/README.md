# Repository Infrastructure

This part contains the registry of the repositories used for the project,
as well as the access roles and permission for Github actions.


## Usage
Update the `terraform.tfvars` file with the required values,
set proper backend configuration in `provider.tf` file
and run the following commands to create the infrastructure.

```bash
terraform init
terraform apply -var-file=terraform.tfvars
```