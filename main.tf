terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.44.0"
    }
  }

  backend "s3" {
    bucket = "landigu-tf-remote-state"
    key    = "generate-values-infra/terraform.tfstate"
    region = "sa-east-1"
  }
}

provider "aws" {
  region = "sa-east-1"
  default_tags {
    tags = {
      owner      = "Gustavo Landi"
      managed-by = "terraform"
    }
  }
}
