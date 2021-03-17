# dev-infra

Reusable bits of infrastructure for testing/dev work, deployed/managed
with [Terragrunt](https://terragrunt.gruntwork.io).

## Usage

Update terragrunt.hcl files to fit your needs. The files are hierarchical,
so `/terragrunt.hcl` contains common settings while
`/us-east-1/vpc/terragrunt.hcl` contains settings that only apply to
a VPC in us-east-1.

Then with Terragrunt
[installed](https://terragrunt.gruntwork.io/docs/getting-started/install/):

```bash
# See what would happen to deploy a single VPC
terragrunt plan --terragrunt-working-dir us-east-1/vpc

# which is equivalent to:
cd us-east-1/vpc && terragrunt plan

# See what would happen if we deploy everything
terragrunt run-all plan

# Substitute "apply" for "plan" to actually make changes
```
