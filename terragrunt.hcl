locals {
  state_bucket = get_env("STATE_BUCKET", "tfstate-${try(get_aws_account_id(), "local")}")
  region_config = read_terragrunt_config(find_in_parent_folders("region.hcl", "defaults.hcl"))

  # Shorthand
  aws_region = local.region_config.locals.aws_region

  # We might have extra provider config settings for localstack
  extra_provider_config = tostring(try(local.region_config.locals.extra_provider_config, ""))
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
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket         = local.state_bucket
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "terragrunt-tflock"
  }
}

skip = true
