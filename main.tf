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

# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "2.64.0"

#   cidr = var.vpc_cidr_block

#   azs             = data.aws_availability_zones.available.names
#   private_subnets = slice(var.private_subnet_cidr_blocks, 0, var.private_subnet_count)
#   public_subnets  = slice(var.public_subnet_cidr_blocks, 0, var.public_subnet_count)

#   enable_nat_gateway = true
#   enable_vpn_gateway = var.enable_vpn_gateway

#   tags = var.resource_tags
# }

# module "app_security_group" {
#   source  = "terraform-aws-modules/security-group/aws//modules/web"
#   version = "3.17.0"

#   name        = "web-sg-project-alpha-dev"
#   description = "Security group for web-servers with HTTP ports open within VPC"
#   vpc_id      = module.vpc.vpc_id

#   ingress_cidr_blocks = module.vpc.public_subnets_cidr_blocks

#   tags = var.resource_tags
# }

# module "lb_security_group" {
#   source  = "terraform-aws-modules/security-group/aws//modules/web"
#   version = "3.17.0"

#   name        = "lb-sg-project-alpha-dev"
#   description = "Security group for load balancer with HTTP ports open within VPC"
#   vpc_id      = module.vpc.vpc_id

#   ingress_cidr_blocks = ["0.0.0.0/0"]

#   tags = var.resource_tags
# }

# resource "random_string" "lb_id" {
#   length  = 3
#   special = false
# }

# module "elb_http" {
#   source  = "terraform-aws-modules/elb/aws"
#   version = "2.4.0"

#   # Ensure load balancer name is unique
#   name = "lb-${random_string.lb_id.result}-project-alpha-dev"

#   internal = false

#   security_groups = [module.lb_security_group.this_security_group_id]
#   subnets         = module.vpc.public_subnets

#   number_of_instances = length(module.ec2_instances.instance_ids)
#   instances           = module.ec2_instances.instance_ids

#   listener = [{
#     instance_port     = "80"
#     instance_protocol = "HTTP"
#     lb_port           = "80"
#     lb_protocol       = "HTTP"
#   }]

#   health_check = {
#     target              = "HTTP:80/index.html"
#     interval            = 10
#     healthy_threshold   = 3
#     unhealthy_threshold = 10
#     timeout             = 5
#   }

#   tags = var.resource_tags
# }

# module "ec2_instances" {
#   source = "./modules/aws-instance"

#   instance_count     = var.instance_count
#   instance_type      = var.ec2_instance_type
#   subnet_ids         = module.vpc.private_subnets[*]
#   security_group_ids = [module.app_security_group.this_security_group_id]

#   tags = var.resource_tags
# }

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