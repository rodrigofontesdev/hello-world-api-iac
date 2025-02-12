terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.86.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "terraform-state" {
  bucket        = "hello-world-api-iac"
  force_destroy = true
  lifecycle {
    prevent_destroy = true
  }
  tags = {
    IAC = "True"
  }
}

resource "aws_s3_bucket_versioning" "terraform-state" {
  bucket = "hello-world-api-iac"
  versioning_configuration {
    status = "Enabled"
  }
}
