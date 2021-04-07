terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnet_ids" "selected" {
  vpc_id = var.vpc_id

  filter {
    name   = "tag:Name"
    values = [var.subnet_name_filter]
  }
}

resource "aws_ec2_client_vpn_endpoint" "main" {
  description            = "client-vpn"
  server_certificate_arn = aws_acm_certificate.server.arn # todo
  client_cidr_block      = var.vpn_client_cidr

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.client.arn
  }


  dns_servers = [cidrhost(data.aws_vpc.selected.cidr_block, 2)]

  connection_log_options {
    enabled = false
  }

  tags = var.tags
}

resource "aws_ec2_client_vpn_authorization_rule" "main" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  target_network_cidr    = "0.0.0.0/0"
  authorize_all_groups   = true
}

resource "aws_ec2_client_vpn_network_association" "main" {
  for_each = data.aws_subnet_ids.selected.ids

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  subnet_id              = each.value
  security_groups        = [var.security_group]
}

resource "aws_ec2_client_vpn_route" "main" {
  # Explicitly depending on the association should help avoid some timing issues
  for_each = aws_ec2_client_vpn_network_association.main

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  destination_cidr_block = "0.0.0.0/0"
  target_vpc_subnet_id   = each.value.subnet_id
}

resource "tls_private_key" "server" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "server" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.server.private_key_pem

  subject {
    common_name  = "server.com"
    organization = "server"
  }

  validity_period_hours = 12

  uris = ["server"]

  allowed_uses = [
    "server_auth"
  ]
}

resource "aws_acm_certificate" "server" {
  private_key      = tls_private_key.server.private_key_pem
  certificate_body = tls_self_signed_cert.server.cert_pem
}

resource "tls_private_key" "client" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "client" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.client.private_key_pem

  subject {
    common_name  = "client.com"
    organization = "client"
  }

  validity_period_hours = 12

  uris = ["client"]

  allowed_uses = [
    "client_auth"
  ]
}

resource "aws_acm_certificate" "client" {
  private_key      = tls_private_key.client.private_key_pem
  certificate_body = tls_self_signed_cert.client.cert_pem
}

resource "local_file" "ovpn" {
  content = templatefile(
    "${path.module}/client.ovpn.tpl",
    {
      dns_name : replace(aws_ec2_client_vpn_endpoint.main.dns_name, "*.", "")
      server_cert : tls_self_signed_cert.server.cert_pem,
      client_cert : tls_self_signed_cert.client.cert_pem,
      client_key : tls_private_key.client.private_key_pem
    }
  )
  filename        = "${path.root}/client.ovpn"
  file_permission = "0400"
}

output "vpn_client_config" {
  description = "Path to the client.ovpn file"
  value = abspath(local_file.ovpn.filename)
}
