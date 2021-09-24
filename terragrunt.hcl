locals {
  state_bucket  = get_env("STATE_BUCKET", "tfstate-${try(get_aws_account_id(), "local")}")
  region_config = read_terragrunt_config(find_in_parent_folders("region.hcl", "defaults.hcl"))

  # Shorthand
  aws_region = local.region_config.locals.aws_region

  # We might have extra provider config settings for localstack
  extra_provider_config = tostring(try(local.region_config.locals.extra_provider_config, ""))
  remote_state_backend = try(local.region_config.locals.remote_state_backend, "s3")
  remote_state_config = try(local.region_config.locals.remote_state_config, {
    bucket         = local.state_bucket
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "terragrunt-tflock"
  })
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"

${local.extra_provider_config}
}
EOF
}

remote_state {
  backend = local.remote_state_backend

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = local.remote_state_config
}

skip = true
