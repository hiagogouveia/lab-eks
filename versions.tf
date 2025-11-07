terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # Trava na v5.x, que é compatível com os módulos EKS/VPC abaixo
      version = "~> 5.0"
    }
    # Adicionamos o 'random' para gerar nomes únicos
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}