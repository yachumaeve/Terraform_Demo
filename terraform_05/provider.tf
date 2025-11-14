terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.9.0"
    }
  }
}

provider "aws" {
  region     = "eu-west-1"
  access_key = "AKIAZI2LHRVTAVWGVBOP"
  secret_key = "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"
}