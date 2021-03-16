output "azs" {
  value = module.dev_vpc.azs
}

output "vpc_id" {
  value = module.dev_vpc.vpc_id
}

output "private_subnets" {
  value = module.dev_vpc.private_subnets
}

output "public_subnets" {
  value = module.dev_vpc.public_subnets
}
