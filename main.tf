terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.6.6"
}

# To create the resources in the specified region
provider "aws" {
  region = var.aws_region
}

# To run the VPC module
module "vpc" {
  source                  = "./modules/vpc"
  aws_region              = var.aws_region
  vpc_cidr_block          = var.vpc_cidr_block
  availability_zones      = var.availability_zones
  public_subnet_cidrs     = var.public_subnet_cidrs
  frontend_subnet_cidrs   = var.frontend_subnet_cidrs
  backend_subnet_cidrs    = var.backend_subnet_cidrs
  data_subnet_cidrs       = var.data_subnet_cidrs
  }

  module "targetgroups" {
  source    = "./modules/targetgroups"
  vpc_id    = module.vpc.vpc_id
}

module "frontendalb" {
  source                       = "./modules/frontendalb"
  vpc_id                       = module.vpc.vpc_id
  public_subnet_cidrs          = module.vpc.public_subnet_ids
  target_group_frontend_arn    = module.targetgroups.target_group_frontend_arn
}

module "backendalb" {
  source                      = "./modules/backendalb"
  vpc_id                      = module.vpc.vpc_id
  backend_subnet_ids          = module.vpc.backend_subnet_ids
  target_group_backend_arn    = module.targetgroups.target_group_backend_arn
  frontend_ecs_sg_id          = module.fargate.frontend_ecs_sg_id
}


module "fargate" {
  source                      = "./modules/fargate"
  vpc_id                      = module.vpc.vpc_id
  frontend_subnet1            = module.vpc.frontend_subnet1
  frontend_subnet2            = module.vpc.frontend_subnet2  
  backend_subnet1             = module.vpc.backend_subnet1
  backend_subnet2             = module.vpc.backend_subnet2  
  target_group_frontend_arn   = module.targetgroups.target_group_frontend_arn
  frontend_alb_sg_id          = module.frontendalb.frontend_alb_sg_id
  target_group_backend_arn    = module.targetgroups.target_group_backend_arn
  backend_alb_sg_id           = module.backendalb.backend_alb_sg_id
  backend_listener_id         = module.backendalb.backend_listener_id
}

#Added by rumana
module "bastion" {
  source             = "./modules/bastion"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids  # Ensure this is correctly passed
  ami_id             = var.bastion_ami_id
  instance_type      = var.bastion_instance_type
  key_name           = var.bastion_key_name
  allowed_ssh_cidr   = var.bastion_allowed_ssh_cidr
}

module "api_gateway" {
  source       = "./modules/api_gateway"
  api_name     = var.api_name
  stage_name   = var.stage_name
  alb_arn      = module.frontendalb.alb_arn   # Pass ALB ARN correctly
  alb_dns_name = module.frontendalb.alb_dns_name  # Correct module reference
}


module "waf" {
  source = "./modules/waf"
  waf_name = var.waf_name
  api_gateway_stage_arn = module.api_gateway.api_gateway_stage_arn
}



