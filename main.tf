provider "aws" {
  region = "eu-central-1"
}

terraform {

  required_providers {
    aws      = "~> 3.22"
    template = "~> 2.2"
    random   = "~> 3.0"
  }
  required_version = "~> 0.14"

  backend "remote" {
    organization = "FlamaCorp"

    workspaces {
      name = "tfe-aws-es"
    }
  }
}

data "terraform_remote_state" "vpc" {
  backend = "remote"

  config = {
    organization = "FlamaCorp"
    workspaces = {
      name = "tf-aws-vpc"
    }
  }
}

data "terraform_remote_state" "lb" {
  backend = "remote"

  config = {
    organization = "FlamaCorp"
    workspaces = {
      name = "tf-aws-lb"
    }
  }
}

resource "aws_key_pair" "tfe_key" {
  key_name   = "${var.owner}-tfe-es-ha"
  public_key = var.cloud_pub
}


resource "random_password" "enc_password" {
  length  = 16
  special = false
}

resource "random_id" "user_token" {
  byte_length = 16
}

resource "random_id" "install_id" {
  byte_length = 16
}

resource "random_id" "root_secret" {
  byte_length = 16
}

resource "random_id" "archivist_token" {
  byte_length = 16
}

resource "random_id" "cookie_hash" {
  byte_length = 16
}

resource "random_id" "internal_api_token" {
  byte_length = 16
}

resource "random_id" "registry_session_encryption_key" {
  byte_length = 16
}

resource "random_id" "registry_session_secret_key" {
  byte_length = 16
}
