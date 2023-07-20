terraform {
  cloud {
    organization = "PANW-Terraform-Labs"
    hostname     = "app.terraform.io"

    workspaces {
      name = "terraform-runtasks"
    }
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region  = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "badbucket" {
  source = "./modules/s3-bucket"

  bucket_acl = var.bucket_acl

  versioning_enabled = var.versioning_enabled
}

resource "aws_instance" "app" {

  ami           = "ami-0507f77897697c4ba"
  instance_type = var.instance_type

  user_data = <<EOF
#! /bin/bash
sudo apt-get update
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMAAA
export AWS_SECRET_ACCESS_KEY=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
export AWS_DEFAULT_REGION=us-west-2
echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
EOF
}