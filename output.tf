output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

# Added by Rumana
output "alb_arn" {
  description = "The ARN of the Application Load Balancer"
  value       = module.frontendalb.alb_arn
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = module.frontendalb.alb_dns_name
}

output "api_gateway_id" {
  description = "The ID of the API Gateway"
  value       = module.api_gateway.api_gateway_id
}

output "waf_acl_arn" {
  description = "The ARN of the WAF Web ACL"
  value       = module.waf.waf_acl_arn
}
# Output for Bastion Host
output "bastion_instance_id" {
  description = "The ID of the Bastion Host instance"
  value       = module.bastion.bastion_instance_id
}

output "bastion_public_ip" {
  description = "The public IP of the Bastion Host"
  value       = module.bastion.bastion_public_ip
}
