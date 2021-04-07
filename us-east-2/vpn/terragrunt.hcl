include {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_parent_terragrunt_dir()}//modules/vpn"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  vpc_id         = dependency.vpc.outputs.vpc_id
  security_group = "sg-013204ada489aeed3"

  tags = {
    Owner       = "aj"
    Environment = "dev"
  }
}
